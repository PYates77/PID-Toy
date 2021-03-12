# PID Toy
An educational PID controller simulator

Written in [Processing](https://processing.org/download/)

Maybe some of my implementation details are inaccurate. Feel free to bully me about it

## What is [PID controller](https://en.wikipedia.org/wiki/PID_controller)?
Lets say you have a motor. The motor's speed is dependent on the amount of voltage you give it, positive voltage the motor turns forward, negative voltage it drives backward, lots of voltage it turns fast, low voltage it turns slow. You want to make the motor turn so it reaches a certain angle. So the angle between where the motor is right now and where you want it to be is the *error*. 

So the error value gets fed into the PID controller, the controller does some math and outputs a voltage you should use to drive the motor at. Do that a bajillion times a second and the PID controller should drive the motor to exactly the right angle and park it there.

### Math
The PID controller equation for input error *e(t)* and output *u(t)* is based on three *gain* values *K<sub>p</sub>*, *K<sub>i</sub>*, *K<sub>d</sub>*

![Stolen from wikipedia](https://wikimedia.org/api/rest_v1/media/math/render/svg/69072d4013ea8f14ab59a8283ef216fb958870b2)

### Intuitive understanding
In General:

* P is *proportional gain*: If you're far away from where you want to be, push hard
* I is *integral gain*: If you've been far away for a long time, push harder
* D is *derivative gain*: If error is getting smaller fast, slow down.

Some people call D the "dampening" instead of "derivative gain" becuase that's really it's purpose



