(
var count = 0, last = Main.elapsedTime;
// Compile the bundled synths without requiring an audio device in CI.
~dirt = SuperDirt(2);
if(SynthDescLib.global.at(\superpiano).isNil) {
    "FAIL: superpiano SynthDef missing; check SC3 plugins".postln;
    1.exit;
};
"PASS: superpiano SynthDef loaded".postln;
if(thisProcess.openUDPPort(57120).not) { "OSC port occupied".postln; 1.exit; };
OSCdef(\kitTest, { count = count + 1; last = Main.elapsedTime; }, '/dirt/play', recvPort: 57120);
"OSC_RECEIVER_READY".postln;
Routine({
    var waited = 0;
    while { File.exists("/tmp/kit-osc-finished").not and: { waited < 120 } } {
        0.1.wait;
        waited = waited + 0.1;
    };
    if(File.exists("/tmp/kit-osc-finished").not) {
        "FAIL: timed out waiting for Tidal".postln;
        1.exit;
    };
    2.5.wait;
    if((count >= 3) and: { (Main.elapsedTime - last) > 2 }) {
        ("PASS: OSC events and hush: " ++ count).postln; 0.exit;
    } { ("FAIL: events=" ++ count).postln; 1.exit; };
}).play(AppClock);
)
