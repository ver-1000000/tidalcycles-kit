// Kit-owned startup: do not read a user's startup.scd or Quarks configuration.
(
var samplePath = "TIDAL_KIT_SAMPLES".getenv;
if(samplePath.isNil) { "Missing TIDAL_KIT_SAMPLES; start with podman compose up --build".postln; 1.exit; };
s.options.numInputBusChannels = 0;
s.options.numOutputBusChannels = 2;
s.options.numBuffers = 16384;
s.options.memSize = 65536;
s.options.maxNodes = 32768;
s.options.numWireBufs = 2048;
if("TIDAL_AUDIO_DEVICE".getenv.notNil) {
    s.options.device = "TIDAL_AUDIO_DEVICE".getenv;
};
s.waitForBoot({
    ~dirt = SuperDirt(2, s);
    ~dirt.loadSoundFiles(samplePath);
    s.sync;
    ~dirt.start(57120, 0 ! 12, NetAddr("TIDAL_DIRT_HOST".getenv ? "127.0.0.1"));
    File.use("/tmp/tidal-audio-ready", "w", { |file| file.write("ready\n") });
    "TIDAL_KIT_AUDIO_READY".postln;
}, 100, { "SuperCollider failed to boot".postln; 1.exit; });
)
