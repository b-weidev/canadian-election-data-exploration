DROP VIEW IF EXISTS LeaderRidings CASCADE;
DROP VIEW IF EXISTS RidingWinner CASCADE;
DROP VIEW IF EXISTS LeaderWinner CASCADE;
DROP VIEW IF EXISTS PercentLeaderWins CASCADE;
DROP VIEW IF EXISTS LeaderLoser CASCADE;
DROP VIEW IF EXISTS PartyResults CASCADE;
DROP VIEW IF EXISTS LeaderLoserParty CASCADE;

-- Question 1

CREATE VIEW LeaderRidings AS
SELECT e.eid, c.riding, c.cid, c.candidateName, c.party
FROM electionResult e
JOIN candidate c on e.cid = c.cid
WHERE e.leader = true;

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

CREATE VIEW LeaderWinner AS
SELECT COUNT(*) AS LeaderWins
FROM LeaderRidings lr
JOIN RidingWinner rw on lr.eid = rw.eid and lr.riding = rw.riding
WHERE lr.cid = rw.cid;

CREATE VIEW PercentLeaderWins AS
SELECT (
    CAST(
        (CAST(MAX(lw.LeaderWins) AS REAL) / 
        CAST(COUNT(lr) AS REAL))*100 
    AS INT)
) AS PercentWins
FROM LeaderWinner lw, LeaderRidings lr;

-- Q3 Query 1
DROP VIEW IF EXISTS Q3_Query_1;
CREATE VIEW Q3_Query_1 AS
    SELECT * FROM PercentLeaderWins;

--  80% of leader win their riding

-- Who are the 20%?
CREATE VIEW LeaderLoser AS
SELECT lr.eid, lr.cid, lr.candidateName, lr.party, lr.riding
FROM LeaderRidings lr
JOIN RidingWinner rw on lr.eid = rw.eid and lr.riding = rw.riding
WHERE lr.cid <> rw.cid;
SELECT * FROM LeaderLoser;

-- How did their parties do?
CREATE VIEW PartyResults AS
SELECT eid, party, count(*) AS ridingsWon
FROM RidingWinner
GROUP BY eid, party;

-- Q3 Query 2
DROP VIEW IF EXISTS Q3_Query_2;
CREATE VIEW Q3_Query_2 AS
    SELECT * FROM PartyResults;
