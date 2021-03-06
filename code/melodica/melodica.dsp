import("stdfaust.lib");
freq = hslider("freq", 590, 20, 20000, 0.01);
gate = button("gate") : en.asr(0.003, 1, 0.03);
readpressure = hslider("breath[BELA: ANALOG_0]", 0, -1.35, 1, 0.001)*-1 - offset;
sensitivity = hslider("sensitivity[BELA: ANALOG_4]", 0.3, -0.6, 0.9, 0.01) : si.smoo;
offset = hslider("offset[BELA: ANALOG_5]", 0.1, 0, 0.4, 0.01) : si.smoo;
//PBup = hslider("PBup[BELA: ANALOG_1]", 0, 0, 50, 0.1) - 11 : si.smooth(0.9995) : max(0);  // FSR
//PBdown = hslider("PBdown[BELA: ANALOG_2]", 0, 0, 50, 0.1) - 11 : si.smooth(0.9995) : max(0);  // FSR

pressure = readpressure : si.smooth(0.99988) : max(0);
pGate = gate : en.ar(0.03, 0.3)*pressure*(pressure - 0.3 : max(0))*3;
breath = (readpressure + pGate - .05) / (1-sensitivity) : si.smooth(0.996) : max(0);

clip = breath*0.75+2.7;

fs = hslider("fundamental subtract", 0.55, 0, 3, 0.01) : si.smoo;

vibratoOsc = os.osc(4);

sine = os.osc(freq);
reed = (((((sine*clip*2 -1) : ef.cubicnl(0,0))+1)/2 + (sine*2+1 : ef.cubicnl(0,0)-1)*0.1 -sine*fs)-breath/3)*breath*gate : fi.lowpass(2, 8000);

noise = gate : ba.impulsify : en.ar(0.005, 0.1) : (_ + 0.1*breath*gate + 0.1) * (no.noise : fi.bandpass(2,850,2000))*pressure : fi.highpass(2, 900);

process = (reed + noise*0.1)*0.02 : fi.highpass(1,600) <: _,_;
