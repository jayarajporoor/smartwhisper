function WhisperGenerateAndSend()

fs = 48000;

hash = WhisperGetHash();

samples=WhisperGenerator(hash);

wavplay(samples, fs);