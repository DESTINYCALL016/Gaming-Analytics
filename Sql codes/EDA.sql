select * from Online_Game

--Age Distribution Check

Select count(case when age<=18 then playerId end) as teen, count(case when age>18 then playerid end) as adult
from
Online_Game

--Removing Descrepency

Update Online_Game 
set PlayTimeHours= 0
where SessionsPerWeek= 0

--Finding trends in Engagement Level.

Select PlayerID,EngagementLevel, PlayTimeHours, InGamePurchases,SessionsPerWeek,AvgSessionDurationMinutes 
from
Online_Game

-- Bifurcating Age on the basis of behaviour.
/*
Alter table online_Game
add Age_Group varchar(50)

Alter Table online_Game
drop column Age_Group

*/

-- Creating Age Group Columns
With Age_Grouped as (
select PlayerID,
	   case 
			when Age<=19 then 'Teen' 
			when Age>19 and Age<=24 then 'Young Adults'
			when Age>24 and Age<=29 then 'Early Career'
			when Age>29 and Age<=39 then 'Mature Adults'
			else 'Older Adults'
	   end as Age_Groups
from
Online_Game
)
Update o
set o.Age_Group=a.Age_Groups
from
Online_Game as o
join
Age_Grouped as a
on
o.PlayerID=a.PlayerID

-- Player Distribution per Age group

Select Age_group, count(playerId) as Counts , cast((Count(playerID) *100.0/(Select count(PlayerID) from Online_Game)) as numeric(10,2)) as Distributions
from 
Online_Game 
group by Age_Group 
order by Distributions desc

--Distribution with respect to engagement level and age groups

Select Age_Group, EngagementLevel,Count(PlayerID) as Counts ,cast((Count(PlayerID)*100.0/(Select Count(PlayerID) from Online_Game)) as numeric(10,2)) as Distributions
from
Online_Game
Group by Age_Group, EngagementLevel
order by Age_Group, Distributions desc

-- AvgSessionDurationHours with respect to age_group and EngagementLevel

Select Age_Group, EngagementLevel,cast(Avg((AvgSessionDurationMinutes/60.0)) as numeric(10,2)) as AvgSessionDurationHours
from
Online_Game
Group by Age_Group, EngagementLevel
order by Age_group, AvgSessionDurationHours desc

--Weekly Play time in minutes

Alter Table online_game
add WeeklyPlayTimeMinutes int

update Online_Game
set WeeklyPlayTimeMinutes = PlayTimeHours*60

-- Average Weekly Play Time

Alter Table online_game
add AvgWeeklyPlayTime int

update Online_Game
set AvgWeeklyPlayTime =Case when SessionsPerWeek=0 then 0 else Ceiling( WeeklyPlayTimeMinutes*1.0/SessionsPerWeek) end

-- Trend label creation 
/*
ALTER TABLE Online_Game
ADD TrendLabel VARCHAR(20);

UPDATE Online_Game
SET TrendLabel =
    CASE 
        WHEN ((AvgWeeklyPlayTime - AvgSessionDurationMinutes) * 100.0 / AvgSessionDurationMinutes) > 30 THEN 'Strong Up'
        WHEN ((AvgWeeklyPlayTime - AvgSessionDurationMinutes) * 100.0 / AvgSessionDurationMinutes) BETWEEN 20 AND 30 THEN 'Up'
        WHEN ((AvgWeeklyPlayTime - AvgSessionDurationMinutes) * 100.0 / AvgSessionDurationMinutes) BETWEEN -20 AND 20 THEN 'Stable'
        WHEN ((AvgWeeklyPlayTime - AvgSessionDurationMinutes) * 100.0 / AvgSessionDurationMinutes) BETWEEN -30 AND -20 THEN 'Down'
        WHEN ((AvgWeeklyPlayTime - AvgSessionDurationMinutes) * 100.0 / AvgSessionDurationMinutes) < -30 THEN 'Strong Down'
    END;

*/


Select TrendLabel , count(playerid) playerCount from Online_Game group by TrendLabel

--Change percent in Trend

/*
ALTER TABLE Online_Game
ADD TrendPercent FLOAT;

UPDATE Online_Game
SET TrendPercent = 
    Cast(((AvgWeeklyPlayTime - AvgSessionDurationMinutes) * 100.0 / AvgSessionDurationMinutes) as numeric(10,2));
*/

Select * from Online_Game

-- In Game Purchase Label

/*
Alter  Table Online_Game
Add PurchaseLabel varchar(50)

Update Online_Game
set PurchaseLabel=Case when InGamePurchases=1 then 'Purchased'
                       else 'NotPurchased'
                  end
*/

Select * from Online_Game where AvgWeeklyPlaytime=1439

-- Avg Weekly Play Time label the player 

/*
Alter table online_Game
Add PlayTimeLabel varchar(20)


With Ntiles_group as(
SELECT 
    PlayerID,
    AvgWeeklyPlayTime,
    NTILE(3) OVER (ORDER BY AvgWeeklyPlayTime) AS DurationBucket
FROM Online_Game
)
update o
set PlaytimeLabel=Case when g.DurationBucket=1 then 'Casual' 
                       when g.DurationBucket=2 then 'Engaged'
                       when g.DurationBucket=3 then 'Heavy'
                    end
from 
Online_Game as o
join 
Ntiles_group as g
on
o.PlayerID=g.playerid
*/

Select * from Online_Game

-- creating Sessions Per Week Label column

/*
Alter Table online_game
add FrequencyLabel varchar(50)

Update Online_Game
Set FrequencyLabel=Case when SessionsPerWeek Between 0 and 5 then 'Low'
                        when SessionsPerWeek Between 6 and 12 then 'Medium' 
                        when SessionsPerWeek Between 13 and 19 then 'High'
                    end

*/

-- Merged duration plus frequency

/*
Alter table online_game
add PlayerType varchar(50)

Update Online_Game
SET PlayerType = CONCAT(PlayTimeLabel, ' Gamer - ', FrequencyLabel, ' Frequency');

*/


--Player Type Distribution
Select PlayerType,count(playerid) as TypeCount, cast((count(playerid)*100.0/(Select count(playerId) from Online_Game)) as numeric(10,2)) as Percent_Distribution
from 
Online_Game 
group by PlayerType 
order by TypeCount desc

Select * from Online_Game

-- Player Tier 
Alter Table Online_Game
add PlayerTier Varchar(50)

Update Online_Game
set PlayerTier=case when PlayerLevel<=33 then 'Low-Tier'
                    when PlayerLevel>66 then 'High-Tier'
                    else 'Mid-Tier'
                end

Select min(AchievementsUnlocked),max(achievementsunlocked) from Online_Game

-- Achievments Label
Alter Table Online_Game
add AchievementLabel Varchar(50)

Update Online_Game
SET AchievementLabel = CASE
    WHEN AchievementsUnlocked BETWEEN 0 AND 15 THEN 'Explorer'
    WHEN AchievementsUnlocked BETWEEN 16 AND 30 THEN 'Veteran'
    WHEN AchievementsUnlocked BETWEEN 31 AND 49 THEN 'Completionist'
END;

Select * from Online_Game

-- Player profile
Alter Table Online_Game
Drop column PlayerProfile

ALTER TABLE Online_Game
ADD PlayerProfile VARCHAR(100)

UPDATE Online_Game
SET PlayerProfile = CONCAT(
    PlayerTier, ' | ',
    LEFT(PlayerType, CHARINDEX(' -', PlayerType) - 1), ' | ',
    RIGHT(PlayerType, LEN(PlayerType) - CHARINDEX(' - ', PlayerType) - 2), ' | ',
    AchievementLabel
);


Select * from Online_Game

--PlayerProfile Distribution 
Select PlayerProfile,count(playerid) as TypeCount, cast((count(playerid)*100.0/(Select count(playerId) from Online_Game)) as numeric(10,2)) as Percent_Distribution
from 
Online_Game 
group by PlayerProfile 
order by TypeCount desc

-- ProfileTrendCombo 
ALTER TABLE Online_Game
ADD ProfileTrendCombo VARCHAR(200);

UPDATE Online_Game
SET ProfileTrendCombo = CONCAT(PlayerProfile, ' | ', TrendLabel);

-- columns Summery
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Online_Game';

Select * from Online_Game

Update Online_Game
set PurchaseLabel= case when PurchaseLabel='NotPurchased' then 'NonSpender'
                        when PurchaseLabel='Purchased' then 'Spender'
                    end

UPDATE Online_Game
SET PlayerProfile = CONCAT(
    PlayerTier, ' | ',
    LEFT(PlayerType, CHARINDEX(' -', PlayerType) - 1), ' | ',
    RIGHT(PlayerType, LEN(PlayerType) - CHARINDEX(' - ', PlayerType) - 2), ' | ',
    AchievementLabel, ' | ',
    PurchaseLabel
);

UPDATE Online_Game
SET ProfileTrendCombo = CONCAT(
    PlayerTier, ' | ',
    LEFT(PlayerType, CHARINDEX(' -', PlayerType) - 1), ' | ',
    RIGHT(PlayerType, LEN(PlayerType) - CHARINDEX(' - ', PlayerType) - 2), ' | ',
    AchievementLabel, ' | ',
    PurchaseLabel, ' | ',
    TrendLabel
);

Select * from Online_Game

--PlayerProfile + Trend Distribution 
Select ProfileTrendCombo,count(playerid) as TypeCount, cast((count(playerid)*100.0/(Select count(playerId) from Online_Game)) as numeric(10,2)) as Percent_Distribution
from 
Online_Game 
group by ProfileTrendCombo
order by TypeCount desc

/*

alter table online_game
drop column PlayerType

alter table online_game
drop column WeeklyPlayTimeMinutes

alter table online_game
drop column InGamePurchases

alter table online_game
drop column PlayerProfile

*/

Select *
from
INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='Online_Game'

ALTER TABLE Online_Game ADD InGamePurchases int
UPDATE Online_Game SET InGamePurchases = CASE WHEN PurchaseLabel = 'Spender' THEN 1 ELSE 0 END

Select * from Online_Game

Alter table Online_Game
add Clusters Varchar(10)

Update Online_Game
set clusters= case when cluster =0 then 'K1'
                  when cluster =1 then 'K2'
                  when cluster =2 then 'K3'
                  when cluster =3 then 'K4'
                  when cluster =4 then 'K5'
                  when cluster =5 then 'K6'
            end

Alter Table Online_Game
drop column cluster


-- Engagement level Percent Distribution per Cluster

With Clusters_Player_Count as (
Select Clusters,count(playerid) as Player_Count
from
Online_Game
group by Clusters
)
Select o.Clusters, o.EngagementLevel, Count(PlayerID) as Count, Cast((Count(PlayerID)*100.0/c.Player_count) as numeric(10,2)) as Percent_Distribution
from
Online_Game as o
join
Clusters_Player_Count as C
on
o.clusters=c.clusters
group by o.Clusters, o.EngagementLevel,c.Player_Count
order by o.clusters, Percent_Distribution desc


-- Game Difficulty Percent Distribution per Cluster
Select * from Online_Game

With Clusters_Player_Count as (
Select Clusters,count(playerid) as Player_Count
from
Online_Game
group by Clusters
)
Select o.Clusters, o.GameDifficulty, Count(PlayerID) as Count, Cast((Count(PlayerID)*100.0/c.Player_count) as numeric(10,2)) as Percent_Distribution
from
Online_Game as o
join
Clusters_Player_Count as C
on
o.clusters=c.clusters
group by o.Clusters, o.GameDifficulty,c.Player_Count
order by o.clusters, Percent_Distribution desc

-- Game Genre Percent Distribution per Cluster
Select * from Online_Game

With Clusters_Player_Count as (
Select Clusters,count(playerid) as Player_Count
from
Online_Game
group by Clusters
)
Select o.Clusters, o.GameGenre, Count(PlayerID) as Count, Cast((Count(PlayerID)*100.0/c.Player_count) as numeric(10,2)) as Percent_Distribution
from
Online_Game as o
join
Clusters_Player_Count as C
on
o.clusters=c.clusters
group by o.Clusters, o.GameGenre,c.Player_Count
order by o.clusters, Percent_Distribution desc

-- Location Percent Distribution per Cluster
Select * from Online_Game

With Clusters_Player_Count as (
Select Clusters,count(playerid) as Player_Count
from
Online_Game
group by Clusters
)
Select o.Clusters, o.[Location], Count(PlayerID) as Count, Cast((Count(PlayerID)*100.0/c.Player_count) as numeric(10,2)) as Percent_Distribution
from
Online_Game as o
join
Clusters_Player_Count as C
on
o.clusters=c.clusters
group by o.Clusters, o.[Location],c.Player_Count
order by o.clusters, Percent_Distribution desc

-- Age Group Percent Distribution per Cluster
Select * from Online_Game

With Clusters_Player_Count as (
Select Clusters,count(playerid) as Player_Count
from
Online_Game
group by Clusters
)
Select o.Clusters, o.Age_Group, Count(PlayerID) as Count, Cast((Count(PlayerID)*100.0/c.Player_count) as numeric(10,2)) as Percent_Distribution
from
Online_Game as o
join
Clusters_Player_Count as C
on
o.clusters=c.clusters
group by o.Clusters, o.Age_Group,c.Player_Count
order by o.clusters, Percent_Distribution desc


-- Gender Percent Distribution per Cluster
Select * from Online_Game

With Clusters_Player_Count as (
Select Clusters,count(playerid) as Player_Count
from
Online_Game
group by Clusters
)
Select o.Clusters, o.Gender, Count(PlayerID) as Count, Cast((Count(PlayerID)*100.0/c.Player_count) as numeric(10,2)) as Percent_Distribution
from
Online_Game as o
join
Clusters_Player_Count as C
on
o.clusters=c.clusters
group by o.Clusters, o.Gender,c.Player_Count
order by o.clusters, Percent_Distribution desc

-- Trend Percent Distribution per Cluster
Select * from Online_Game

With Clusters_Player_Count as (
Select Clusters,count(playerid) as Player_Count
from
Online_Game
group by Clusters
)
Select o.Clusters, o.TrendLabel, Count(PlayerID) as Count, Cast((Count(PlayerID)*100.0/c.Player_count) as numeric(10,2)) as Percent_Distribution
from
Online_Game as o
join
Clusters_Player_Count as C
on
o.clusters=c.clusters
group by o.Clusters, o.TrendLabel,c.Player_Count
order by o.clusters, Percent_Distribution desc

-- PurchaseLabel Percent Distribution per Cluster
Select * from Online_Game

With Clusters_Player_Count as (
Select Clusters,count(playerid) as Player_Count
from
Online_Game
group by Clusters
)
Select o.Clusters, o.PurchaseLabel, Count(PlayerID) as Count, Cast((Count(PlayerID)*100.0/c.Player_count) as numeric(10,2)) as Percent_Distribution
from
Online_Game as o
join
Clusters_Player_Count as C
on
o.clusters=c.clusters
group by o.Clusters, o.PurchaseLabel,c.Player_Count
order by o.clusters, Percent_Distribution desc

-- PlayTimeLabel Percent Distribution per Cluster
Select * from Online_Game

With Clusters_Player_Count as (
Select Clusters,count(playerid) as Player_Count
from
Online_Game
group by Clusters
)
Select o.Clusters, o.PlayTimeLabel, Count(PlayerID) as Count, Cast((Count(PlayerID)*100.0/c.Player_count) as numeric(10,2)) as Percent_Distribution
from
Online_Game as o
join
Clusters_Player_Count as C
on
o.clusters=c.clusters
group by o.Clusters, o.PlayTimeLabel,c.Player_Count
order by o.clusters, Percent_Distribution desc

-- Frequency Percent Distribution per Cluster
Select * from Online_Game

With Clusters_Player_Count as (
Select Clusters,count(playerid) as Player_Count
from
Online_Game
group by Clusters
)
Select o.Clusters, o.FrequencyLabel, Count(PlayerID) as Count, Cast((Count(PlayerID)*100.0/c.Player_count) as numeric(10,2)) as Percent_Distribution
from
Online_Game as o
join
Clusters_Player_Count as C
on
o.clusters=c.clusters
group by o.Clusters, o.FrequencyLabel,c.Player_Count
order by o.clusters, Percent_Distribution desc

-- Player Tier Percent Distribution per Cluster
Select * from Online_Game

With Clusters_Player_Count as (
Select Clusters,count(playerid) as Player_Count
from
Online_Game
group by Clusters
)
Select o.Clusters, o.PlayerTier, Count(PlayerID) as Count, Cast((Count(PlayerID)*100.0/c.Player_count) as numeric(10,2)) as Percent_Distribution
from
Online_Game as o
join
Clusters_Player_Count as C
on
o.clusters=c.clusters
group by o.Clusters, o.PlayerTier,c.Player_Count
order by o.clusters, Percent_Distribution desc

-- Achievement Label Percent Distribution per Cluster
Select * from Online_Game

With Clusters_Player_Count as (
Select Clusters,count(playerid) as Player_Count
from
Online_Game
group by Clusters
)
Select o.Clusters, o.AchievementLabel, Count(PlayerID) as Count, Cast((Count(PlayerID)*100.0/c.Player_count) as numeric(10,2)) as Percent_Distribution
from
Online_Game as o
join
Clusters_Player_Count as C
on
o.clusters=c.clusters
group by o.Clusters, o.AchievementLabel,c.Player_Count
order by o.clusters, Percent_Distribution desc

-- Distinct Player Profiles  per Cluster
Select * from Online_Game

Select Clusters,count(Distinct ProfileTrendCombo) as DistinctProfiles
from 
Online_Game
group by Clusters

--Numerical Data averages.
Select Clusters, Avg(Age) as AvgAge, Avg(SessionsPerWeek*1.0) as AvgSessionsPerWeek, Avg(AvgSessionDurationMinutes) as AvgLifeLongSessionDuration,
                 Avg(PlayerLevel) as AvgPlayerLevel,Avg(AchievementsUnlocked) as AvgAchievementsUnlocked,Avg(AvgWeeklyPlayTime) as  WeekAvgPlayTime,
                 Avg(TrendPercent) as AvgTrendPercent
                 into Clusters_Numeric
from 
Online_Game
group by Clusters 

-- Clusters_Numeric
SELECT * 
FROM 
Clusters_Numeric 
ORDER BY WeekAvgPlayTime DESC


--


With Clusters_Player_Count as (
Select Clusters , Count(playerid) as Player_Count
from
Online_Game
group by Clusters
),

Engagement as (
Select o.Clusters, o.EngagementLevel, Count(PlayerID) as Count, Cast((Count(PlayerID)*100.0/c.Player_count) as numeric(10,2)) as Percent_Distribution
from
Online_Game as o
join
Clusters_Player_Count as C
on
o.clusters=c.clusters
group by o.Clusters, o.EngagementLevel,c.Player_Count

)


,GameDifficulty as (
Select o.Clusters, o.GameDifficulty, Count(PlayerID) as Count, Cast((Count(PlayerID)*100.0/c.Player_count) as numeric(10,2)) as Percent_Distribution
from
Online_Game as o
join
Clusters_Player_Count as C
on
o.clusters=c.clusters
group by o.Clusters, o.GameDifficulty,c.Player_Count

)
-- Game Genre Percent Distribution per Cluster

,GameGenre as (

Select o.Clusters, o.GameGenre, Count(PlayerID) as Count, Cast((Count(PlayerID)*100.0/c.Player_count) as numeric(10,2)) as Percent_Distribution
from
Online_Game as o
join
Clusters_Player_Count as C
on
o.clusters=c.clusters
group by o.Clusters, o.GameGenre,c.Player_Count

)
-- Location Percent Distribution per Cluster

, [Location] as (



Select o.Clusters, o.[Location], Count(PlayerID) as Count, Cast((Count(PlayerID)*100.0/c.Player_count) as numeric(10,2)) as Percent_Distribution
from
Online_Game as o
join
Clusters_Player_Count as C
on
o.clusters=c.clusters
group by o.Clusters, o.[Location],c.Player_Count

)
-- Age Group Percent Distribution per Cluster
,Age_Group as (




Select o.Clusters, o.Age_Group, Count(PlayerID) as Count, Cast((Count(PlayerID)*100.0/c.Player_count) as numeric(10,2)) as Percent_Distribution
from
Online_Game as o
join
Clusters_Player_Count as C
on
o.clusters=c.clusters
group by o.Clusters, o.Age_Group,c.Player_Count


)
-- Gender Percent Distribution per Cluster

, Gender as (



Select o.Clusters, o.Gender, Count(PlayerID) as Count, Cast((Count(PlayerID)*100.0/c.Player_count) as numeric(10,2)) as Percent_Distribution
from
Online_Game as o
join
Clusters_Player_Count as C
on
o.clusters=c.clusters
group by o.Clusters, o.Gender,c.Player_Count

)
-- Trend Percent Distribution per Cluster


, Trend as (


Select o.Clusters, o.TrendLabel, Count(PlayerID) as Count, Cast((Count(PlayerID)*100.0/c.Player_count) as numeric(10,2)) as Percent_Distribution
from
Online_Game as o
join
Clusters_Player_Count as C
on
o.clusters=c.clusters
group by o.Clusters, o.TrendLabel,c.Player_Count

), purchaseLabel as (
-- PurchaseLabel Percent Distribution per Cluster



Select o.Clusters, o.PurchaseLabel, Count(PlayerID) as Count, Cast((Count(PlayerID)*100.0/c.Player_count) as numeric(10,2)) as Percent_Distribution
from
Online_Game as o
join
Clusters_Player_Count as C
on
o.clusters=c.clusters
group by o.Clusters, o.PurchaseLabel,c.Player_Count

)
-- PlayTimeLabel Percent Distribution per Cluster


, playTimeLabel as (


Select o.Clusters, o.PlayTimeLabel, Count(PlayerID) as Count, Cast((Count(PlayerID)*100.0/c.Player_count) as numeric(10,2)) as Percent_Distribution
from
Online_Game as o
join
Clusters_Player_Count as C
on
o.clusters=c.clusters
group by o.Clusters, o.PlayTimeLabel,c.Player_Count

),
-- Frequency Percent Distribution per Cluster

Frequency as (



Select o.Clusters, o.FrequencyLabel, Count(PlayerID) as Count, Cast((Count(PlayerID)*100.0/c.Player_count) as numeric(10,2)) as Percent_Distribution
from
Online_Game as o
join
Clusters_Player_Count as C
on
o.clusters=c.clusters
group by o.Clusters, o.FrequencyLabel,c.Player_Count

)
-- Player Tier Percent Distribution per Cluster

, Player_Tier as (


Select o.Clusters, o.PlayerTier, Count(PlayerID) as Count, Cast((Count(PlayerID)*100.0/c.Player_count) as numeric(10,2)) as Percent_Distribution
from
Online_Game as o
join
Clusters_Player_Count as C
on
o.clusters=c.clusters
group by o.Clusters, o.PlayerTier,c.Player_Count

)
-- Achievement Label Percent Distribution per Cluster


, AchievementLabel as (


Select o.Clusters, o.AchievementLabel, Count(PlayerID) as Count, Cast((Count(PlayerID)*100.0/c.Player_count) as numeric(10,2)) as Percent_Distribution
from
Online_Game as o
join
Clusters_Player_Count as C
on
o.clusters=c.clusters
group by o.Clusters, o.AchievementLabel,c.Player_Count

)

, final_Union as (
Select * from Engagement
union all
Select * from GameDifficulty
union all
Select * from GameGenre
union all
Select * from [Location]
union all 
Select * from Age_Group
union all
Select * from Gender
union all
Select * from Trend
union all
Select * from purchaseLabel
union all
Select * from playTimeLabel
union all
Select * from Frequency
union all
Select * from Player_Tier
union all
Select * from AchievementLabel

)
Select * into Cluster_Categorical from final_Union
Order by clusters, Percent_Distribution

Select * from Cluster_Categorical

Select Distinct Clusters
from
Online_Game

Alter Table online_game
add cluster_label varchar(50)


Update Online_Game
set cluster_label= case 
                   when Clusters='K1' then 'Casual Achievers'
                   when Clusters='K2' then 'Burnt-Out Enthusiasts'
                   when Clusters='K3' then 'Disengaged Explorers'
                   when Clusters='K4' then 'Emerging Grinders'
                   when Clusters='K5' then 'Balanced Casuals'
                   when Clusters='K6' then 'Growing Explorers'
              end


Select * from Online_Game

Select Clusters, cluster_label,Avg(Age) as AvgAge,count(PlayerID) as Players, cast(Avg(PlayTimeHours *60) as numeric(10,2)) as AvgWeekPlayTime, cast(Avg(SessionsPerWeek*1.0) as numeric(10,2)) as AvgWeekSessions,  cast(Avg(AvgSessionDurationMinutes ) as numeric(10,2)) as AvgLifeLongDuration, Avg(PlayerLevel) as AvgPlayerLevel,Avg(AchievementsUnlocked) as AvgAchievementsBagged, cast(Avg(TrendPercent) as numeric(10,2)) as AvgTrend, sum(InGamePurchases) as SpendersCount 
into Cluster_Table
from 
Online_Game
Group by Clusters, Cluster_label 

Select * From Cluster_Table


-- Cluster Summary with Engagement % split
With Clusters_Player_Count as (
    Select Clusters, count(PlayerID) as Player_Count
    from Online_Game
    group by Clusters
)
Select 
    o.Clusters,
    c.Player_Count,
    -- Engagement %
    cast(100.0*sum(case when EngagementLevel='Low' then 1 else 0 end)/c.Player_Count as numeric(10,2)) as Engagement_Low_Pct,
    cast(100.0*sum(case when EngagementLevel='Medium' then 1 else 0 end)/c.Player_Count as numeric(10,2)) as Engagement_Medium_Pct,
    cast(100.0*sum(case when EngagementLevel='High' then 1 else 0 end)/c.Player_Count as numeric(10,2)) as Engagement_High_Pct
from Online_Game o
join Clusters_Player_Count c
  on o.Clusters=c.Clusters
group by o.Clusters, c.Player_Count
order by o.Clusters;



-- MASTER CLUSTER PROFILE TABLE
Select  
    Clusters,
    cluster_label,

    -- Player count
    count(PlayerID) as TotalPlayers,

    -- Numerical Summaries
    Avg(Age) as AvgAge,
    Cast(Avg(PlayTimeHours*60) as numeric(10,2)) as AvgWeekPlayTime,
    Cast(Avg(SessionsPerWeek*1.0) as numeric(10,2)) as AvgWeekSessions,
    Cast(Avg(AvgSessionDurationMinutes) as numeric(10,2)) as AvgLifeLongDuration,
    Avg(PlayerLevel) as AvgPlayerLevel,
    Avg(AchievementsUnlocked) as AvgAchievementsBagged,
    Cast(Avg(TrendPercent) as numeric(10,2)) as AvgTrend,
    Sum(case when InGamePurchases=1 then 1 else 0 end) as SpendersCount,

    -- Engagement Level %
    Cast(100.0*Sum(case when EngagementLevel='Low' then 1 else 0 end)/Count(*) as numeric(10,2)) as Engagement_Low_Pct,
    Cast(100.0*Sum(case when EngagementLevel='Medium' then 1 else 0 end)/Count(*) as numeric(10,2)) as Engagement_Medium_Pct,
    Cast(100.0*Sum(case when EngagementLevel='High' then 1 else 0 end)/Count(*) as numeric(10,2)) as Engagement_High_Pct,

    -- PlayTime Label %
    Cast(100.0*Sum(case when PlayTimeLabel='Casual' then 1 else 0 end)/Count(*) as numeric(10,2)) as PlayTime_Light_Pct,
    Cast(100.0*Sum(case when PlayTimeLabel='Engaged' then 1 else 0 end)/Count(*) as numeric(10,2)) as PlayTime_Medium_Pct,
    Cast(100.0*Sum(case when PlayTimeLabel='Heavy' then 1 else 0 end)/Count(*) as numeric(10,2)) as PlayTime_Heavy_Pct,

    -- Frequency Label %
    Cast(100.0*Sum(case when FrequencyLabel='Low' then 1 else 0 end)/Count(*) as numeric(10,2)) as Freq_Low_Pct,
    Cast(100.0*Sum(case when FrequencyLabel='Medium' then 1 else 0 end)/Count(*) as numeric(10,2)) as Freq_Medium_Pct,
    Cast(100.0*Sum(case when FrequencyLabel='High' then 1 else 0 end)/Count(*) as numeric(10,2)) as Freq_High_Pct,

    -- Achievement Label %
    Cast(100.0*Sum(case when AchievementLabel='Completionist' then 1 else 0 end)/Count(*) as numeric(10,2)) as Ach_Completionist_Pct,
    Cast(100.0*Sum(case when AchievementLabel='Explorer' then 1 else 0 end)/Count(*) as numeric(10,2)) as Ach_Explorer_Pct,
    Cast(100.0*Sum(case when AchievementLabel='Veteran' then 1 else 0 end)/Count(*) as numeric(10,2)) Ach_Veteran_Pct

    into Cluster_Table2
from Online_Game 
Group by Clusters, cluster_label
Order by Clusters;

Select * from Cluster_Table2

-------------------------------------------------------------------------------------
Select * from Online_Game

-- Gender distribution
Select Gender , count(PlayerID) as PlayerCount ,cast(count(PlayerID)*100.0/(Select count(PlayerID) from Online_Game) as numeric(10,2)) as Percent_Distribution
from 
Online_Game
group by Gender

--Location Distribution
Select [Location] , count(PlayerID) as PlayerCount ,cast(count(PlayerID)*100.0/(Select count(PlayerID) from Online_Game) as numeric(10,2)) as Percent_Distribution
from 
Online_Game
group by [Location]

-- GameGenre Distribution
Select GameGenre , count(PlayerID) as PlayerCount ,cast(count(PlayerID)*100.0/(Select count(PlayerID) from Online_Game) as numeric(10,2)) as Percent_Distribution
from 
Online_Game
group by GameGenre

-- GameDifficulty Distribution
Select GameDifficulty , count(PlayerID) as PlayerCount ,cast(count(PlayerID)*100.0/(Select count(PlayerID) from Online_Game) as numeric(10,2)) as Percent_Distribution
from 
Online_Game
group by GameDifficulty

Select * from Online_Game

-- Engagement Level Distribution
Select EngagementLevel , count(PlayerID) as PlayerCount ,cast(count(PlayerID)*100.0/(Select count(PlayerID) from Online_Game) as numeric(10,2)) as Percent_Distribution
from 
Online_Game
group by EngagementLevel

--Age_Group Distribution
Select Age_Group , count(PlayerID) as PlayerCount ,cast(count(PlayerID)*100.0/(Select count(PlayerID) from Online_Game) as numeric(10,2)) as Percent_Distribution
from 
Online_Game
group by Age_Group

Select * from Online_Game

-- Trend Distribution
Select TrendLabel , count(PlayerID) as PlayerCount ,cast(count(PlayerID)*100.0/(Select count(PlayerID) from Online_Game) as numeric(10,2)) as Percent_Distribution
from 
Online_Game
group by TrendLabel

-- Spender vs Non Spender 
Select PurchaseLabel , count(PlayerID) as PlayerCount ,cast(count(PlayerID)*100.0/(Select count(PlayerID) from Online_Game) as numeric(10,2)) as Percent_Distribution
from 
Online_Game
group by PurchaseLabel

-- Gender Playtime Distribution
Select Gender, cast(Avg(PlayTimeHours)*60 as numeric(10,2)) AvgPlayTime
from
Online_Game
group by Gender

--Location Playtime Distribution
Select [Location], cast(Avg(PlayTimeHours)*60 as numeric(10,2)) AvgPlayTime
from
Online_Game
group by [Location]

--GameGenre Playtime Distribution
Select GameGenre, cast(Avg(PlayTimeHours)*60 as numeric(10,2)) AvgPlayTime
from
Online_Game
group by GameGenre

--Game Difficulty Playtime Distribution
Select GameDifficulty, cast(Avg(PlayTimeHours)*60 as numeric(10,2)) AvgPlayTime
from
Online_Game
group by GameDifficulty

--Age Groups Playtime Distribution
Select Age_Group, cast(Avg(PlayTimeHours)*60 as numeric(10,2)) AvgPlayTime
from
Online_Game
group by Age_Group

-- Trend Label Playtime Distribution
Select TrendLabel, cast(Avg(PlayTimeHours)*60 as numeric(10,2)) AvgPlayTime
from
Online_Game
group by TrendLabel

--Purchase Label Playtime Distribution
Select PurchaseLabel, cast(Avg(PlayTimeHours)*60 as numeric(10,2)) AvgPlayTime
from
Online_Game
group by PurchaseLabel


---------------------------------------------------------
-- Gender PlaySessions Distribution
Select Gender, cast(Avg(SessionsPerWeek*1.0) as numeric(10,2)) AvgPlaySession
from
Online_Game
group by Gender

--Location PlaySessions Distribution
Select [Location], cast(Avg(SessionsPerWeek*1.0) as numeric(10,2)) AvgPlaySession
from
Online_Game
group by [Location]

--GameGenre PlaySessions Distribution
Select GameGenre, cast(Avg(SessionsPerWeek*1.0) as numeric(10,2)) AvgPlaySession
from
Online_Game
group by GameGenre

--Game Difficulty PlaySessions Distribution
Select GameDifficulty, cast(Avg(SessionsPerWeek*1.0) as numeric(10,2)) AvgPlaySession
from
Online_Game
group by GameDifficulty

--Age Groups PlaySessions Distribution
Select Age_Group, cast(Avg(SessionsPerWeek*1.0) as numeric(10,2)) AvgPlaySession
from
Online_Game
group by Age_Group

-- Trend Label PlaySessions Distribution
Select TrendLabel, cast(Avg(SessionsPerWeek*1.0) as numeric(10,2)) AvgPlaySession
from
Online_Game
group by TrendLabel

--Purchase Label PlaySessions Distribution
Select PurchaseLabel, cast(Avg(SessionsPerWeek*1.0) as numeric(10,2)) AvgPlaySession
from
Online_Game
group by PurchaseLabel

Select * from Online_Game

---------------------------------------------------------------------------
-- Gender Player Level Distribution
Select Gender, cast(Avg(PlayerLevel*1.0) as numeric(10,2)) AvgPlayerLevel
from
Online_Game
group by Gender

--Location Player Level Distribution
Select [Location], cast(Avg(PlayerLevel*1.0) as numeric(10,2)) AvgPlayerLevel
from
Online_Game
group by [Location]

--GameGenre Player Level Distribution
Select GameGenre, cast(Avg(PlayerLevel*1.0) as numeric(10,2)) AvgPlayerLevel
from
Online_Game
group by GameGenre

--Game Difficulty Player Level Distribution
Select GameDifficulty, cast(Avg(PlayerLevel*1.0) as numeric(10,2)) AvgPlayerLevel
from
Online_Game
group by GameDifficulty

--Age Groups Player Level Distribution
Select Age_Group, cast(Avg(PlayerLevel*1.0) as numeric(10,2)) AvgPlayerLevel
from
Online_Game
group by Age_Group

-- Trend Label Player Level Distribution
Select TrendLabel, cast(Avg(PlayerLevel*1.0) as numeric(10,2)) AvgPlayerLevel
from
Online_Game
group by TrendLabel

--Purchase Label Player Level Distribution
Select PurchaseLabel, cast(Avg(PlayerLevel*1.0) as numeric(10,2)) AvgPlayerLevel
from
Online_Game
group by PurchaseLabel

Select * from Online_Game

-------------------------------------------------------------------------------
-- Gender Achievement Bagged Distribution
Select Gender, cast(Avg(AchievementsUnlocked*1.0) as numeric(10,2)) AvgAchievementBagged
from
Online_Game
group by Gender

--Location Achievement Bagged Distribution
Select [Location], cast(Avg(AchievementsUnlocked*1.0) as numeric(10,2)) AvgAchievementBagged
from
Online_Game
group by [Location]

--GameGenre Achievement Bagged Distribution
Select GameGenre, cast(Avg(AchievementsUnlocked*1.0) as numeric(10,2)) AvgAchievementBagged
from
Online_Game
group by GameGenre

--Game Difficulty Achievement Bagged Distribution
Select GameDifficulty, cast(Avg(AchievementsUnlocked*1.0) as numeric(10,2)) AvgAchievementBagged
from
Online_Game
group by GameDifficulty

--Age Groups Achievement Bagged Distribution
Select Age_Group, cast(Avg(AchievementsUnlocked*1.0) as numeric(10,2)) AvgAchievementBagged
from
Online_Game
group by Age_Group

-- Trend Label Achievement Bagged Distribution
Select TrendLabel, cast(Avg(AchievementsUnlocked*1.0) as numeric(10,2)) AvgAchievementBagged
from
Online_Game
group by TrendLabel

--Purchase Label Achievement Bagged Distribution
Select PurchaseLabel, cast(Avg(AchievementsUnlocked*1.0) as numeric(10,2)) AvgAchievementBagged
from
Online_Game
group by PurchaseLabel

----------------------------------------------------------------------------
--Cluster wise Distribution

--EngagementLevel
Select cluster_label, EngagementLevel, count(PlayerID) as PlayerCount
from
Online_Game
where clusters='K1'
group by cluster_label, EngagementLevel

--PlayTime Label
Select cluster_label, PlayTimeLabel, count(PlayerID) as PlayerCount
from
Online_Game
where clusters='K1'
group by cluster_label, PlayTimeLabel

--Frequency Label
Select cluster_label, FrequencyLabel, count(PlayerID) as PlayerCount
from
Online_Game
where clusters='K1'
group by cluster_label, FrequencyLabel

--Player Tier Label
Select cluster_label, PlayerTier, count(PlayerID) as PlayerCount
from
Online_Game
where clusters='K1'
group by cluster_label, PlayerTier

---------------------------------------------------------
--EngagementLevel
Select cluster_label, EngagementLevel, count(PlayerID) as PlayerCount
from
Online_Game
where clusters='K2'
group by cluster_label, EngagementLevel

--PlayTime Label
Select cluster_label, PlayTimeLabel, count(PlayerID) as PlayerCount
from
Online_Game
where clusters='K2'
group by cluster_label, PlayTimeLabel

--Frequency Label
Select cluster_label, FrequencyLabel, count(PlayerID) as PlayerCount
from
Online_Game
where clusters='K2'
group by cluster_label, FrequencyLabel

--Player Tier Label
Select cluster_label, PlayerTier, count(PlayerID) as PlayerCount
from
Online_Game
where clusters='K2'
group by cluster_label, PlayerTier

--------------------------------------------------------------------
--EngagementLevel
Select cluster_label, EngagementLevel, count(PlayerID) as PlayerCount
from
Online_Game
where clusters='K3'
group by cluster_label, EngagementLevel

--PlayTime Label
Select cluster_label, PlayTimeLabel, count(PlayerID) as PlayerCount
from
Online_Game
where clusters='K3'
group by cluster_label, PlayTimeLabel

--Frequency Label
Select cluster_label, FrequencyLabel, count(PlayerID) as PlayerCount
from
Online_Game
where clusters='K3'
group by cluster_label, FrequencyLabel

--Player Tier Label
Select cluster_label, PlayerTier, count(PlayerID) as PlayerCount
from
Online_Game
where clusters='K3'
group by cluster_label, PlayerTier

------------------------------------------------------------------------------
--EngagementLevel
Select cluster_label, EngagementLevel, count(PlayerID) as PlayerCount
from
Online_Game
where clusters='K4'
group by cluster_label, EngagementLevel

--PlayTime Label
Select cluster_label, PlayTimeLabel, count(PlayerID) as PlayerCount
from
Online_Game
where clusters='K4'
group by cluster_label, PlayTimeLabel

--Frequency Label
Select cluster_label, FrequencyLabel, count(PlayerID) as PlayerCount
from
Online_Game
where clusters='K4'
group by cluster_label, FrequencyLabel

--Player Tier Label
Select cluster_label, PlayerTier, count(PlayerID) as PlayerCount
from
Online_Game
where clusters='K4'
group by cluster_label, PlayerTier

--------------------------------------------------------------------------
--EngagementLevel
Select cluster_label, EngagementLevel, count(PlayerID) as PlayerCount
from
Online_Game
where clusters='K5'
group by cluster_label, EngagementLevel

--PlayTime Label
Select cluster_label, PlayTimeLabel, count(PlayerID) as PlayerCount
from
Online_Game
where clusters='K5'
group by cluster_label, PlayTimeLabel

--Frequency Label
Select cluster_label, FrequencyLabel, count(PlayerID) as PlayerCount
from
Online_Game
where clusters='K5'
group by cluster_label, FrequencyLabel

--Player Tier Label
Select cluster_label, PlayerTier, count(PlayerID) as PlayerCount
from
Online_Game
where clusters='K5'
group by cluster_label, PlayerTier

-------------------------------------------------------------------------------
--EngagementLevel
Select cluster_label, EngagementLevel, count(PlayerID) as PlayerCount
from
Online_Game
where clusters='K6'
group by cluster_label, EngagementLevel

--PlayTime Label
Select cluster_label, PlayTimeLabel, count(PlayerID) as PlayerCount
from
Online_Game
where clusters='K6'
group by cluster_label, PlayTimeLabel

--Frequency Label
Select cluster_label, FrequencyLabel, count(PlayerID) as PlayerCount
from
Online_Game
where clusters='K6'
group by cluster_label, FrequencyLabel

--Player Tier Label
Select cluster_label, PlayerTier, count(PlayerID) as PlayerCount
from
Online_Game
where clusters='K6'
group by cluster_label, PlayerTier
----------------------------------------------------------
--KPI's
Select * from online_game

Select cast(sum(TrendPercent)as numeric(10,2)) as TotalPlayTime 
from online_Game

Select cast(AVG(TrendPercent*1.0)as numeric(10,2)) as Age 
from Online_Game

Select AchievementLabel, cast(count(PlayerID)*100.0/(Select count(playerid) from online_Game) as  numeric(10,2)) 
from Online_Game group by AchievementLabel

Select GameGenre, cast(count(PlayerID)*100.0/(Select count(playerid) from online_Game) as numeric(10,2))
from
Online_Game
where IngamePurchases=1
group by GameGenre

Select clusters, Cluster_label
from Online_Game
group by Clusters, cluster_label