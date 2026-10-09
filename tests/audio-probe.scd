("KIT_TEST_ROOT".getenv ++ "/boot/BootSuperDirt.scd").load;
(
Routine({
    var file, samples, peak, tail, waited = 0;
    while { ~dirt.isNil or: { ~dirt.orbits.isNil } } { 0.1.wait };
    if(SynthDescLib.global.at(\superpiano).isNil) {
        "FAIL: superpiano SynthDef missing; check SC3 plugins".postln;
        1.exit;
    };
    s.recHeaderFormat = "wav";
    s.recSampleFormat = "int16";
    s.prepareForRecord("KIT_TEST_RECORDING".getenv);
    s.sync;
    s.record;
    "KIT_RECORDING_READY".postln;
    while { File.exists("/tmp/kit-recording-finish").not and: { waited < 120 } } {
        0.1.wait;
        waited = waited + 0.1;
    };
    if(File.exists("/tmp/kit-recording-finish").not) {
        "FAIL: timed out waiting for the pattern test".postln;
        1.exit;
    };
    s.stopRecording;
    s.sync;
    0.5.wait;
    file = SoundFile.openRead("KIT_TEST_RECORDING".getenv);
    if(file.isNil) { "FAIL: recording missing".postln; 1.exit; };
    samples = FloatArray.newClear(file.numFrames * file.numChannels);
    file.readData(samples);
    peak = samples.abs.maxItem;
    tail = samples.copyRange((samples.size - (file.sampleRate * file.numChannels)).asInteger.max(0), samples.size - 1).abs.maxItem;
    file.close;
    if((peak > 0.001) and: { tail < 0.001 }) {
        ("PASS: recorded output, peak=" ++ peak ++ ", silent tail=" ++ tail).postln;
        0.exit;
    } { ("FAIL: peak=" ++ peak ++ ", tail=" ++ tail).postln; 1.exit; };
}).play(AppClock);
)
