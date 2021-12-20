DROP VIEW IF EXISTS RidingWinner CASCADE;
DROP VIEW IF EXISTS RidingLoser CASCADE;
DROP VIEW IF EXISTS IncumbentLoser CASCADE;
DROP VIEW IF EXISTS Incumbent CASCADE;
DROP VIEW IF EXISTS ElectionIncumbent;
DROP VIEW IF EXISTS ElectionIncumbentLoser CASCADE;
DROP VIEW IF EXISTS PercentIncumbentLose CASCADE;
DROP VIEW IF EXISTS PartyResult CASCADE;

CREATE VIEW RidingWinner AS
SELECT e.eid, c.riding, c.cid, c.candidateName, c.party
FROM electionResult e
JOIN candidate c on e.cid = c.cid
JOIN (
    SELECT e2.eid, c2.riding, MAX(e2.votes) as votes
    FROM electionResult e2
    JOIN candidate c2 on e2.cid = c2.cid
    GROUP BY e2.eid, c2.riding
) wv on wv.eid = e.eid and wv.riding = c.riding
WHERE e.votes = wv.votes;

CREATE VIEW RidingLoser AS
SELECT e.eid, c.riding, c.cid, c.candidateName, c.party, e.incumbent
FROM electionResult e
JOIN candidate c on e.cid = c.cid
WHERE e.cid NOT IN (
    SELECT rw.cid
    FROM RidingWinner rw
    WHERE rw.eid = e.eid AND rw.riding = c.riding
);

CREATE VIEW IncumbentLoser AS
SELECT *
FROM RidingLoser
WHERE incumbent = true;

-- what percentage of incumbents lose their seats in each election?
CREATE VIEW Incumbent AS
SELECT e.eid, c.cid, c.candidateName, c.party, c.riding
FROM electionResult e
JOIN candidate c ON e.cid = c.cid
WHERE incumbent = true;

CREATE VIEW ElectionIncumbent AS
SELECT eid, COUNT(*) AS COUNT
FROM Incumbent
GROUP BY eid;

CREATE VIEW ElectionIncumbentLoser AS
SELECT eid, COUNT(*) AS COUNT
FROM IncumbentLoser
GROUP BY eid;

-- Q1_Query_1
DROP VIEW IF EXISTS Q1_Query_1;
CREATE VIEW Q1_Query_1 AS 
    SELECT * from ElectionIncumbent;

-- Q1_Query_2
DROP VIEW IF EXISTS Q1_Query_2;
CREATE VIEW Q1_Query_2 AS 
    SELECT * from ElectionIncumbentLoser;
-- counts vary between elections from 38-125, 42 is by far the highest

CREATE VIEW PercentIncumbentLose AS
SELECT t.eid, CAST(
    (CAST(l.count AS REAL) /
    CAST(t.count AS REAL))*100
AS INT) AS PercentLose
FROM ElectionIncumbent t
JOIN ElectionIncumbentLoser l ON t.eid = l.eid;

-- Q1_Query_3
DROP VIEW IF EXISTS Q1_Query_3;
CREATE VIEW Q1_Query_3 AS 
    SELECT * FROM PercentIncumbentLose;

-- percentage generally low, with the exception of 2015 (42)
-- why is 2015 so high?
-- who won then?

CREATE VIEW PartyResult AS
SELECT eid, party, COUNT(*)
FROM RidingWinner 
GROUP BY eid, party
ORDER BY eid, party;

-- Q1_Query_4
DROP VIEW IF EXISTS Q1_Query_4;
CREATE VIEW Q1_Query_4 AS 
    SELECT * FROM PartyResult;
-- from here we can see that the liberal's went from 34 - 184
-- in election 42. This is likely the cause for the high percentage earlier
