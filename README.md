
<h1 align="center">
<b>2D-Bounce</b>
   <br><img width="275" height="500" src="https://user-images.githubusercontent.com/16679908/50730814-41af1980-1124-11e9-80c3-f2d936a6d198.gif">
</h1>

## An example of phisics and animation in swift
Basically, the demo mimics the behavior of spriteKit or cocos2d, without help of third-party libraries

At first it was a demo project of 2D collisions between particles and bounds.
Both particles were spawned with their radius and the initial directions directly in code.
Subsequently, I decided to implement the possibility to initialize the particles with a gesture of two fingers in order to vary the size of the particles. 
The switch for initialization is double-tap, then two fingers expanding movement for the size, then double-tap again to confirm the initialization.
Once the particle is initialized it could be dragged with one finger. 
It is necessary to do the same for the second particle.
Finally the direction of movement is given with launching gesture with one finger.
Also, double-tap may be used to pause or resume animation. 
