function result = WhisperReceiveAndVerify(params)

params
    
total_frame_len = length(params.preamble) + length(WhisperGetHash())
sec=total_frame_len/params.bits_per_sec+0.5
fs = params.samples_per_sec;

recorded_samples = wavrecord(fs*sec, fs);

res=WhisperVerifier(recorded_samples, params);

hash = WhisperGetHash();

if (isequal(res, hash))
    str = 'DEVICE-WHISPER VERIFICATION SUCCESSFUL';
else
    str = 'DEVICE-WHISPER VERIFICATION FAILED';
end

result = str;
