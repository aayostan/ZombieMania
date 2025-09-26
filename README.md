# Zombie Mania
This is an assigment for ATLS 4140 which is being built off of the contents of this tutorial:  
https://www.youtube.com/watch?si=RIg1qYrWa_mMX_Kg&t=2044&v=e1zJS31tr88&feature=youtu.be


## Time Breakdown
Total: ~26.25hrs\
<br/>
Tutorial: ~2hrs  
Change Gun Fire to Clicking Left Mouse Button and Fire in Direction of Cursor: ~0.35hrs  
Add Progression (num bullets fired linked to kills): ~1.5hrs  
Create score tracking and timer: ~1hrs  
Add score and restart button to end screen: ~0.5hrs  
Create Github Repo: ~0.25hrs  
Ideation: ~0.9hrs  
Ammo Counter + Reload: ~1.5hrs  
Firing Type Differentiation: ~1hrs  
Updating UI to Reflect Changes: ~0.75hrs  
Level Gates for Guns and Power Ups: ~2hrs  
New Enemies and Ramping Difficulty: ~2hrs  
UI Improvement + Ammo Tracking Bar: ~3.5hrs  
Passthrough Bullets and Tree Generation: ~1hrs  
SoundFX and Screen Shake Scripts: ~1.25hrs  
Making Sound Effects for the Game: ~2.75hrs  
Added Mob Drops/Pickups to Game: ~4hrs  
Made Mod Drops/Pickups Launch and Bounce: ~4hrs  


## Ideas
1. Extra Game Loop: Ammo and reload (Time: ~1.5hrs)
   - Ammo counter in UI  
   - Reload button binding
   - Define Clip Size + reload delay 
2. Extra Game Loop: Gun Options (Time: ~1.75hrs)
   - Shotgun: bullet spread
   - Machine Gun: burst fire
3. Gates: level gates to unlock guns (Time: ~4hrs)
   - levels based on experience (Time: ~0.75hrs)
   - experience gained by killing enemies (Time: ~0.5hrs)
   - certain gun types unlocked at higher levels (Time: ~0.75hrs)
   - Stretch: add strong enemies for bonus XP (Time: ~2hrs)
4. Added pickups which change the player's stats (Time: ~4.75hrs)
   - bullet go through (Time: ~0.75hrs)
5. Juice (Time: ~4hrs)
   - SoundFX play script (Time: ~0.5hrs)
   - Find SoundFX: Gunshots, reloading, gun switching, damage dealt, level-up... (Time: ~2.75hrs)
   - Screenshake and when to use it.. (Time: ~0.75hr)
6. Army (Time Est.: ~12hrs)
   - Equip multiple guns (Time: ~3hrs)
   - Recruit Multiple Soldiers (Time Est.: ~4hrs)
     - NPC Soldiers auto-fire (Time Est.: ~1hr)
     - NPC Soldiers follow-player (Time Est.: ~1hr)
     - NPC Enemies kill soldiers instead of player (Time Est.: ~2hrs)
   - Gun and Bullet Econonmy from mob drops (Time Est.: ~5hrs)
7. Balance (Time Est.: ~3hrs)
   - Limit total number of mobs and cull by distance to player (Time Est.: ~1.5hrs)
   - Limit powerups by difficulty of mob kill (Time Est.: ~1.5hrs)
8. Levels (Time Est.: ~12hrs)
   - Add Boss Rounds to introduce new mobs 
     - Reusable Boss Round
       - Clear Enemies
       - Boss Health Bar
       - Periodic mob spawn
     - First Boss: Big Mob
       - Move through trees
       - Move slowly toward player
       - Huge Health
     - Second Boss: Fast Mob
       - Stopped by trees
       - Move quickly in straight line, Pause and aim at player    
       - Low Health
     - Third Boss: Big, Fast Mob
       - Move through trees
       - Move quickly in straight line, Pause and aim at player    
       - Mid-Health

## Credit
Soda Can ClipArt: https://clipart-library.com/clipart/blue-can-cliparts-9.htm  
Sandwhich ClipArt: https://toppng.com/show_download/79387/sandwich  
Screen Shake Code: https://github.com/QuebleGameDev/Godot-Screen-Shake/blob/main/shake_camera/shake_camera.gd  
Audio Manager Code: https://github.com/cu-jonas/cozy_cook/tree/main/audio  
Error Explanation: https://forum.godotengine.org/t/what-does-the-cant-change-this-state-while-flushing-queries-error-mean/25559  
Random Inside Unit Circle Code: https://www.reddit.com/r/godot/comments/vjge0n/could_anyone_share_some_code_for_finding_a/ @angelonit  

