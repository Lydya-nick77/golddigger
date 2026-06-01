local ok_ffi, ffi = pcall(require, 'ffi')
local bit = require('bit')

local M = {}

if not ok_ffi then
    function M.Play(path, volume_percent)
        local volume = tonumber(volume_percent) or 100
        if volume <= 0 then
            return
        end
        ashita.misc.play_sound(path)
    end

    function M.Tick()
    end

    return M
end

ffi.cdef[[
    typedef unsigned int UINT;
    typedef unsigned long DWORD;
    typedef unsigned short WORD;
    typedef unsigned long long DWORD_PTR;
    typedef long MMRESULT;
    typedef void* HWAVEOUT;

    typedef struct {
        WORD  wFormatTag;
        WORD  nChannels;
        DWORD nSamplesPerSec;
        DWORD nAvgBytesPerSec;
        WORD  nBlockAlign;
        WORD  wBitsPerSample;
        WORD  cbSize;
    } WAVEFORMATEX;

    typedef struct {
        char*  lpData;
        DWORD  dwBufferLength;
        DWORD  dwBytesRecorded;
        void*  dwUser;
        DWORD  dwFlags;
        DWORD  dwLoops;
        void*  lpNext;
        DWORD  reserved;
    } WAVEHDR;

    MMRESULT waveOutOpen(HWAVEOUT* phwo, UINT uDeviceID, const WAVEFORMATEX* pwfx,
        DWORD_PTR dwCallback, DWORD_PTR dwInstance, DWORD fdwOpen);
    MMRESULT waveOutPrepareHeader(HWAVEOUT hwo, WAVEHDR* pwh, UINT cbwh);
    MMRESULT waveOutWrite(HWAVEOUT hwo, WAVEHDR* pwh, UINT cbwh);
    MMRESULT waveOutUnprepareHeader(HWAVEOUT hwo, WAVEHDR* pwh, UINT cbwh);
    MMRESULT waveOutReset(HWAVEOUT hwo);
    MMRESULT waveOutClose(HWAVEOUT hwo);
]]

local winmm = ffi.load('winmm')

local WAVE_FORMAT_PCM = 1
local WAVE_MAPPER = 0xFFFFFFFF
local CALLBACK_NULL = 0
local WHDR_DONE = 0x00000001

local active = nil

local function cleanup_active()
    if active == nil then
        return
    end

    if active.hwo ~= nil then
        winmm.waveOutReset(active.hwo)
        if active.header ~= nil then
            winmm.waveOutUnprepareHeader(active.hwo, active.header, ffi.sizeof('WAVEHDR'))
        end
        winmm.waveOutClose(active.hwo)
    end

    active = nil
end

local function read_u16(data, offset)
    local b1 = data:byte(offset) or 0
    local b2 = data:byte(offset + 1) or 0
    return bit.bor(b1, bit.lshift(b2, 8))
end

local function read_u32(data, offset)
    local b1 = data:byte(offset) or 0
    local b2 = data:byte(offset + 1) or 0
    local b3 = data:byte(offset + 2) or 0
    local b4 = data:byte(offset + 3) or 0
    return b1 + bit.lshift(b2, 8) + bit.lshift(b3, 16) + bit.lshift(b4, 24)
end

local function parse_pcm16_wav(path)
    local f = io.open(path, 'rb')
    if f == nil then
        return nil
    end

    local data = f:read('*all')
    f:close()

    if data == nil or #data < 44 then
        return nil
    end

    if data:sub(1, 4) ~= 'RIFF' or data:sub(9, 12) ~= 'WAVE' then
        return nil
    end

    local fmt = nil
    local pcm = nil
    local pos = 13

    while pos + 8 <= #data do
        local chunk_id = data:sub(pos, pos + 3)
        local chunk_size = read_u32(data, pos + 4)
        local chunk_start = pos + 8

        if chunk_id == 'fmt ' and chunk_size >= 16 then
            fmt = {
                format_tag = read_u16(data, chunk_start),
                channels = read_u16(data, chunk_start + 2),
                samples_per_sec = read_u32(data, chunk_start + 4),
                avg_bytes_per_sec = read_u32(data, chunk_start + 8),
                block_align = read_u16(data, chunk_start + 12),
                bits_per_sample = read_u16(data, chunk_start + 14),
            }
        elseif chunk_id == 'data' then
            pcm = data:sub(chunk_start, chunk_start + chunk_size - 1)
        end

        pos = chunk_start + chunk_size + (chunk_size % 2)
    end

    if fmt == nil or pcm == nil then
        return nil
    end

    if fmt.format_tag ~= WAVE_FORMAT_PCM or fmt.bits_per_sample ~= 16 then
        return nil
    end

    return fmt, pcm
end

local function scale_pcm_16bit(pcm, volume_percent)
    local multiplier = volume_percent / 100
    local count = math.floor(#pcm / 2)
    local dst = ffi.new('char[?]', #pcm)

    for i = 0, count - 1 do
        local src_index = (i * 2) + 1
        local lo = pcm:byte(src_index) or 0
        local hi = pcm:byte(src_index + 1) or 0
        local sample = bit.bor(lo, bit.lshift(hi, 8))

        if sample >= 32768 then
            sample = sample - 65536
        end

        sample = math.floor(sample * multiplier + (sample >= 0 and 0.5 or -0.5))
        if sample > 32767 then
            sample = 32767
        elseif sample < -32768 then
            sample = -32768
        end

        local unsigned = sample >= 0 and sample or (sample + 65536)
        dst[i * 2] = bit.band(unsigned, 0xFF)
        dst[i * 2 + 1] = bit.band(bit.rshift(unsigned, 8), 0xFF)
    end

    return dst, #pcm
end

local function play_scaled(path, volume_percent)
    local fmt, pcm = parse_pcm16_wav(path)
    if fmt == nil or pcm == nil then
        ashita.misc.play_sound(path)
        return
    end

    cleanup_active()

    local buffer, length = scale_pcm_16bit(pcm, volume_percent)

    local wfx = ffi.new('WAVEFORMATEX')
    wfx.wFormatTag = fmt.format_tag
    wfx.nChannels = fmt.channels
    wfx.nSamplesPerSec = fmt.samples_per_sec
    wfx.nAvgBytesPerSec = fmt.avg_bytes_per_sec
    wfx.nBlockAlign = fmt.block_align
    wfx.wBitsPerSample = fmt.bits_per_sample
    wfx.cbSize = 0

    local hwo = ffi.new('HWAVEOUT[1]')
    local result = winmm.waveOutOpen(hwo, WAVE_MAPPER, wfx, 0, 0, CALLBACK_NULL)
    if result ~= 0 then
        ashita.misc.play_sound(path)
        return
    end

    local header = ffi.new('WAVEHDR')
    header.lpData = buffer
    header.dwBufferLength = length
    header.dwFlags = 0
    header.dwLoops = 0

    result = winmm.waveOutPrepareHeader(hwo[0], header, ffi.sizeof('WAVEHDR'))
    if result ~= 0 then
        winmm.waveOutClose(hwo[0])
        ashita.misc.play_sound(path)
        return
    end

    result = winmm.waveOutWrite(hwo[0], header, ffi.sizeof('WAVEHDR'))
    if result ~= 0 then
        winmm.waveOutUnprepareHeader(hwo[0], header, ffi.sizeof('WAVEHDR'))
        winmm.waveOutClose(hwo[0])
        ashita.misc.play_sound(path)
        return
    end

    active = {
        hwo = hwo[0],
        header = header,
        buffer = buffer,
    }
end

function M.Play(path, volume_percent)
    local volume = tonumber(volume_percent) or 100
    if volume <= 0 then
        return
    end

    if volume >= 100 then
        cleanup_active()
        ashita.misc.play_sound(path)
        return
    end

    play_scaled(path, volume)
end

function M.Tick()
    if active == nil or active.header == nil then
        return
    end

    if bit.band(active.header.dwFlags, WHDR_DONE) ~= 0 then
        cleanup_active()
    end
end

return M
