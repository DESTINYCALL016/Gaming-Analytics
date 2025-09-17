
--New DataBase Creation

/*
Create Database Gaming
Use Gaming
*/


--Data Understanding
Select*
from
Online_Game


--Gender Classifications
Select Distinct Gender
from
Online_Game

--Checking nulls
Select * from Online_game
where  playerid is null or
	   Age is null or
	   gender is null or
	   [location] is null or
	   gamegenre is null or 
	   Playtimehours <=0 or
	   Playtimehours is null or
	   (InGamePurchases != 0 and IngamePurchases !=1) or
	   GameDifficultY is null or 
	   SessionsPerWeek is null or
	   SessionsPerWeek <0 or
	   AvgSessionDurationMinutes is null or
	   AvgSessionDurationMinutes <0 or
	   PlayerLevel is null or
	   PlayerLevel<0 or
	   AchievementsUnlocked<0 or
	   EngagementLevel is null

--Players count
Select PlayerID, count(PlayerId) as Duplicate
from 
Online_Game
group by PlayerId
having count(PlayerID)>	1

Select count(Distinct playerId) as Player_count
from
Online_Game


-- Age Outliers
Select Min(Age) Minimum_Player_Age, Max(Age) Maximum_Player_Age
from
Online_Game

-- Different Locations
Select Distinct [Location]
from
Online_Game

-- Player's count by location
Select [Location] , count(PlayerID) as [Count], Cast(count(PlayerID)*100.0/(Select count(Playerid) from Online_Game) as Numeric(10,2))as Percent_Distribution
from
Online_Game
group by [Location]
order by [count] desc

-- Games Genre
Select GameGenre,count(PlayerID) as [Count] ,cast(count(PlayerID)*100.0/(Select count(PlayerID) from Online_Game) as numeric(10,2)) as Percent_Distribution
from
Online_Game
group by GameGenre
order by [Count] desc

-- Fools Distribution
Select cast(count(case when InGamePurchases=0 then playerid end)*100.0/(Select count(playerid) from Online_Game) as numeric(10,2)) as NotThatStupid_Percent,
       cast(count(case when InGamePurchases=1 then PlayerID end)*100.0/(Select count(playerid) from Online_Game) as numeric(10,2)) as Stupid_Percent
from 
Online_Game

-- Game Difficulty 
Select GameDifficulty,Cast(count(PlayerID)*100.0/(Select count(PlayerID) from Online_Game) as numeric(10,2) ) as Percent_Distribution
from 
Online_Game
group by GameDifficulty
order by Percent_Distribution

-- Game Difficulty vs stupidity Percent Distribution
Select GameDifficulty,Cast(count(PlayerID)*100.0/(Select count(PlayerID) from Online_Game) as numeric(10,2) ) as Percent_Distribution, 
					  cast(count(case when InGamePurchases=0 then playerid end)*100.0/(Select count(playerid) from Online_Game) as numeric(10,2)) as NotThatStupid_Percent,
					  cast(count(case when InGamePurchases=1 then PlayerID end)*100.0/(Select count(playerid) from Online_Game) as numeric(10,2)) as Stupid_Percent
from
Online_Game
group by GameDifficulty

-- Outliers for SessionsPerWeek
Select Min(SessionsPerWeek) as Minimum_Sessions,Max(SessionsPerWeek) as Maximum_Sessions
from 
Online_Game

-- Sessions per week is zero but AvgSessionDurationMinutes is nonZero
Select *
from
GamingBehaviour_Raw
where SessionsPerWeek=0


-- Outliers for AvgSessionDurationMinutes
Select Min(AvgSessionDurationMinutes) as MinAvgSessionDuration,Max(AvgSessionDurationMinutes) as MaxAvgSessionDuration
from 
Online_Game

-- Levels
Select Min(PlayerLevel) as Min_level , Max(PlayerLevel) as Max_Level
from
Online_Game

-- Achievements Outliers
Select Min(AchievementsUnlocked) as MinAchievementsCount , Max(AchievementsUnlocked) as MaxAchievementsCount
from
Online_Game

-- Engagement Levels
Select EngagementLevel, cast(count(PlayerID)*100.0/ (Select count(PlayerID) from Online_Game) as numeric(10,2)) as Percent_Distribution
from 
Online_Game
group by EngagementLevel
order by Percent_Distribution desc

--------------------------------------------------------------Breaking into multiple Tables---------------------------------------------------------------------


-- Creating Raw Untouched Table
/*
Select * into Online_Game_Raw 
from
Online_Game
*/

-- Creating Players table
/*
Select PlayerID,Age,Gender,[Location] into Players 
from
Online_Game
*/

-- Player's InGamePurchase 
/*
Select PlayerID, InGamePurchases,Case when InGamePurchases=0 then 'Purchased'  else 'NotPurchased' end  as PurchaseLabel Into Purchase_Data
from 
Online_Game
*/

-- Player Game Info
/*
Select PlayerID,GameGenre,GameDifficulty into Game_Info
from
Online_Game
*/

-- Gaming Behaviour
/*
Select PlayerID, cast(PlayTimeHours as numeric(10,2)) as PlayTimeHours,SessionsPerWeek,Cast(AvgSessionDurationMinutes/60.0 as numeric(10,2)) as AvgSessionDurationHours into GamingBehaviour
from
Online_Game
*/

-- Player's Accomplishment
/*
Select PlayerID,PlayerLevel,AchievementsUnlocked into GameProgress
from
Online_Game
*/

-- Adding Engagementlevel in newly created GamingBehaviour Table

/*
Alter Table GamingBehaviour
Add EngagementLevel varChar(50)

Update g
set g.Engagementlevel=o.EngagementLevel
from
GamingBehaviour as g
join
Online_Game as o
on
g.PlayerID=o.PlayerID
*/

-- Final Review

Select * from Online_Game


Select *  from Players
Select *  from game_info
Select *  from GameProgress
Select *  from GamingBehaviour
Select *  from Purchase_Data

Select * into Players_Raw from Players
Select * into game_info_Raw from game_info
Select * into GameProgress_Raw from GameProgress
Select * into GamingBehaviour_Raw from GamingBehaviour
Select * into Purchase_Data_Raw from Purchase_Data

-- Differenct in PlayTime and average Playtime * sessions

with Playtime_Difference as(
	Select SessionsPerWeek* AvgSessionDurationHours as weeklyplaytime, PlayTimeHours , PlayerID
	from
	GamingBehaviour
)select PlayerID, abs(playtimehours-weeklyplaytime) as [difference]
from
playtime_Difference


with Playtime_Difference as(
	Select SessionsPerWeek* AvgSessionDurationHours as weeklyplaytime, PlayTimeHours , PlayerID
	from
	GamingBehaviour
)select PlayerID, Playtimehours , weeklyplaytime
from
playtime_Difference
where (playtimehours-weeklyplaytime)<0

---------------------------------------------------GamingBehaviour--------------------------------------


-- Updating and setting PlayTimeHours Zero where SessionsPerWeek is zero

update GamingBehaviour
set PlayTimeHours=0 
where SessionsPerWeek=0

-- Creating Calculated column called AvgWeeklyPlayTime

Alter Table GamingBehaviour
add AvgWeeklyPlayTime Float

Update GamingBehaviour
set AvgWeeklyPlayTime= case	
							when SessionsPerWeek=0 then 0
							else cast(PlayTimeHours/SessionsPerWeek as numeric(10,2))
						end

Select * from GamingBehaviour

Alter table gamingbehaviour
drop column AvgweeklyPlaytime


Select * from Online_Game