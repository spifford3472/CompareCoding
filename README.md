# CompareCoding
Compare implementing a game in Commodore 64 vs Python

**Objective:**
Write a reasonable clone of Yars’ Revenge for the Commodore 64 using Assembly language.  The game will be a single screen with only basic functionality enabled.  
Port the same game and graphics to more modern coding languages after to show the progression of higher languages and their impact on coding length.  
The purpose of the project is to compare the amount of coding required to implement the same game in 40-year-old technology vs modern platforms.  
However modern tools will be used to write the game for old technology, and the code will be generated using a cross compiler and executed via an emulator.

**Game Idea:**
One of the interesting games I played when I was younger was Yars’ Revenge. It was a video game released for the Atari 2600 in 1982.  
It was created by Howard Scott Warshaw and is Atari’s best-selling original game for the Atari 2600.  
It was later ported to the Nitendo GameBoy and GameBoy Color, but never for the Commodore 64.  
I want to create a basic one screen demo of the game on the Commodore 64 with limited functionality as a POC for this programming comparison.
After that is completed I want to port the game to Python.

**Game Play:**
The player controls an insect-like creature called a Yar who must nibble through a barrier to fire his Zorlon Cannon into the breach. 
The objective is to destroy the evil Qotile, which exists on the other side of the barrier. The Qotile can attack the Yar, even if the barrier is undamaged, 
by turning into the Swirl and shooting across the screen. The Yar can hide from a pursuing destroyer missile within a "neutral zone" in the middle of the screen, 
but the Yar cannot shoot while in the zone. The Swirl can kill the Yar anywhere, even inside the neutral zone.

To destroy the Qotile, the player must eat a piece of the shield to create an opening for the Zorlon Cannon, aim the cannon by leading with the Yar, 
then fire the cannon and fly the Yar out of the path of the cannon's shot. If the weapon finds its mark, the game ends. If the cannon blast hits a 
piece of the shield or misses, it is expended. The cannon itself is dangerous because, the fire button launches it and as the cannon tracks the Yar's vertical 
position, players effectively use the Yar itself as a target and therefore must immediately maneuver to avoid being hit by their own shot. 

**Initial Development Differences:**
Before beginning there are several known differences that easily highlight the progress development environments have undergone in the last 40 years.  
Talking about some the architecture in the beginning will help to set the stage and hypothesis of what I expect to see.  
First I’ll discuss the Commodore 64 computer then I’ll discuss my current home development machine, and one of my testing environments.

**Commodore 64 - 1982**
- Introduced in January 1982, and discontinued in April 1994
- Currently hold the Guiness World Record (as of March 2022) as the highest selling computer of all time (13-17 million units)
  -  Had 30% - 40% of the low-end computer market
- Originally sold for $595 (Equivalent to $1640 in 2022)
- **Specs**
  - Built using a MOS 6510 Processor
    - 1.023 MHz with 64K RAM
    - 300x200 pixel display with 16 colors, and supporting 8 hardware sprites
    - Text Mode: 40x25
    - SID 6581 Chip for Sound (Not used in this project)
 
 **Dell XPS-8930 - 2017**
 - **Specs**
  - 64-bit Intel Core i7-8700 @3.20 GHz w/ 6 cores
  - 32GB RAM
  - NVIDIA GeForce GTX 1660 Ti with resolution of 1920x1080 on each of 4 monitors
  - Windows 11 Pro v 10.0.22000
 
 **Development Environments**
 - Commodore 64
  -- Development OS: Windows 11
  - Development IDE: Visual Studio Code v1.65.2
  - Cross Compiler: ACME Compiler v0.97
  - Commodore 64 Emulator: VICE - GTK3 v4.6.1-Win64
  - Commodore 64 Debugger: C64 Debugger v0.64.56
  - Sprite Editor: Sprite Pad v2.0 Beta 1 (Used to replace graph paper and manual hex calculations)
 
- 
