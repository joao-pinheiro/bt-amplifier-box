.PHONY:  all

all: box lid knob test


box:
	openscad amplifier_box.scad -D renderBox=true -o stl/box.stl

lid:
	openscad amplifier_box.scad -D renderLid=true -o stl/lid.stl

knob:
	openscad amplifier_box.scad -D renderKnob=true -o stl/knob.stl

test:
	openscad amplifier_box.scad -D renderTestPlate=true -o stl/testPlate.stl

