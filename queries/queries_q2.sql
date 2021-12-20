-- Queries for second investigative question

-- Winning votes for each riding of each election
-- WinningVotes(EID, riding, maxVotes)
DROP VIEW IF EXISTS WinningVotes;
CREATE VIEW WinningVotes AS
    SELECT EID, riding, max(votes) AS maxVotes
    FROM ElectionResult NATURAL JOIN Candidate
    GROUP BY EID, riding;

-- Winning candidates for each riding of each election
-- Winners (EID, CID, riding, party)
DROP VIEW IF EXISTS Winners;
CREATE VIEW Winners AS 
    SELECT DISTINCT EID, CID, riding, party
    FROM WinningVotes NATURAL JOIN (ElectionResult NATURAL JOIN Candidate)
    WHERE votes = maxVotes; 

-- Get candidate contributions to EID
DROP VIEW IF EXISTS CandidateContributionToElection;
CREATE VIEW CandidateContributionToElection AS
    SELECT *, 
        CASE 
            WHEN contributionDate > '2015-01-19' AND contributionDate <= '2019-10-21' THEN 43
            WHEN contributionDate > '2011-05-02' AND contributionDate <= '2015-10-19' THEN 42
            WHEN contributionDate > '2008-10-14' AND contributionDate <= '2011-05-02' THEN 41
            WHEN contributionDate > '2006-01-23' AND contributionDate <= '2008-10-14' THEN 40
            ELSE 39 
        END AS EID
    FROM CandidateContribution
    WHERE contributionDate > '2004-06-28' AND contributionDate <= '2019-10-21';

-- Get party contributions to EID
DROP VIEW IF EXISTS PartyContributionToElection;
CREATE VIEW PartyContributionToElection AS 
    SELECT *, 
        CASE 
            WHEN contributionDate > '2015-01-19' AND contributionDate <= '2019-10-21' THEN 43
            WHEN contributionDate > '2011-05-02' AND contributionDate <= '2015-10-19' THEN 42
            WHEN contributionDate > '2008-10-14' AND contributionDate <= '2011-05-02' THEN 41
            WHEN contributionDate > '2006-01-23' AND contributionDate <= '2008-10-14' THEN 40
            ELSE 39 
        END AS EID
    FROM PartyContribution
    WHERE contributionDate > '2004-06-28' AND contributionDate <= '2019-10-21';


-- Query 1

-- Total donations to each candidate for each election
-- TotalCandidateContributions(EID, CID, riding, totalContributions)
DROP VIEW IF EXISTS TotalCandidateContributions;
CREATE VIEW TotalCandidateContributions AS 
    SELECT EID, CID, riding, sum(amount) AS totalContributions
    FROM CandidateContributionToElection NATURAL JOIN Candidate
    GROUP BY EID, riding, CID; 

-- Get average for each election
-- AvgCandidateContributions(EID, riding, avgContributions)
DROP VIEW IF EXISTS AvgCandidateContributions;
CREATE VIEW AvgCandidateContributions AS 
    SELECT EID, riding, avg(totalContributions) AS avgContributions
    FROM TotalCandidateContributions
    GROUP BY EID, riding;

-- Get contributions to winners
-- WinnerContributions(EID, CID, totalContributions)
DROP VIEW IF EXISTS WinnerContributions;
CREATE VIEW WinnerContributions AS 
    SELECT EID, CID, riding, totalContributions 
    FROM TotalCandidateContributions NATURAL JOIN Winners;

-- Get amount of data on winner contributions
-- WinnerDataCount(dataCount)
DROP VIEW IF EXISTS WinnerDataCount;
CREATE VIEW WinnerDataCount AS 
    SELECT count(*) AS dataCount
    FROM WinnerContributions;

-- See how many total winners there are with higher than average contirbutions
-- NumWinnersAboveAvgContributions(numAboveAvg)
DROP VIEW IF EXISTS NumWinnersAboveAvgContributions;
CREATE VIEW NumWinnersAboveAvgContributions AS 
    SELECT count(*) AS numAboveAvg
    FROM WinnerContributions NATURAL JOIN AvgCandidateContributions
    WHERE totalContributions >= avgContributions;

-- Q2_Query_1 
-- Q2_Query_1
DROP VIEW IF EXISTS Q2_Query_1;
CREATE VIEW Q2_Query_1 AS 
    SELECT cast(numAboveAvg AS FLOAT) / cast(dataCount AS FLOAT) AS percentHigherThanAvgContributions
    FROM NumWinnersAboveAvgContributions, WinnerDataCount;


-- Query 2

-- Get maximum donations of those in their riding
-- MaxContributions(EID, riding, maxContribution)
DROP VIEW IF EXISTS MaxCandidateContributions;
CREATE VIEW MaxCandidateContributions AS 
    SELECT EID, riding, max(totalContributions) AS maxContributions
    FROM TotalCandidateContributions
    GROUP BY EID, riding;

-- Get number of winners who have received maximum contributions
-- NumMaxWinners(numMaxWinners)
DROP VIEW IF EXISTS MaxWinners;
CREATE VIEW MaxWinners AS 
    SELECT count(*) AS numMaxWinners
    FROM WinnerContributions NATURAL JOIN MaxCandidateContributions 
    WHERE totalContributions >= maxContributions;

-- Q2_Query_2
DROP VIEW IF EXISTS Q2_Query_2;
CREATE VIEW Q2_Query_2 AS 
    SELECT cast(numMaxWinners AS FLOAT) / cast(dataCount AS FLOAT) AS percentMaxContributions
    FROM MaxWinners, WinnerDataCount;


-- Query 3

-- Get party results for each year
DROP VIEW IF EXISTS PartyResults;
CREATE VIEW PartyResults AS 
    SELECT EID, party, count(riding) AS ridingsWon
    FROM Winners
    GROUP BY EID, party;

-- Get maximum ridings for each election
DROP VIEW IF EXISTS PartyWinningNumbers;
CREATE VIEW PartyWinningNumbers AS 
    SELECT EID, max(ridingsWon) AS winningRidings
    FROM PartyResults
    GROUP BY EID;

-- Get party winners
-- PartyWinners(EID, party)
DROP VIEW IF EXISTS PartyWinners;
CREATE VIEW PartyWinners AS 
    SELECT DISTINCT p1.EID, 
        CASE
            WHEN p1.party = 'Liberal' THEN 'Liberal Party of Canada'
            WHEN p1.party = 'Conservative' THEN 'Conservative Party of Canada'
        END AS party
    FROM PartyResults AS p1, PartyWinningNumbers AS p2
    WHERE p1.EID = p2.EID AND ridingsWon = winningRidings;

-- Get parties and total donations for each election
DROP VIEW IF EXISTS TotalPartyContributions;
CREATE VIEW TotalPartyContributions AS 
    SELECT EID, party, sum(amount) AS partyContributions
    FROM PartyContributionToElection
    GROUP BY EID, party;

-- Get max for each election
DROP VIEW IF EXISTS MaxPartyContributions;
CREATE VIEW MaxPartyContributions AS 
    SELECT EID, max(partyContributions) AS maxPartyDonations
    FROM TotalPartyContributions
    GROUP BY EID;

DROP VIEW IF EXISTS PartyWinnerContributions;
CREATE VIEW PartyWinnerContributions AS 
    SELECT EID, party, partyContributions
    FROM PartyWinners NATURAL JOIN TotalPartyContributions;

DROP VIEW IF EXISTS MaxPartyWinners;
CREATE VIEW MaxPartyWinners AS   
    SELECT count(*) AS numMaxWinner
    FROM PartyWinnerContributions NATURAL JOIN MaxPartyContributions
    WHERE partyContributions >= maxPartyDonations;

DROP VIEW IF EXISTS PartyDataCount;
CREATE VIEW PartyDataCount AS 
    SELECT count(*) AS dataCount
    FROM MaxPartyContributions;

-- Q2_Query_3
DROP VIEW IF EXISTS Q2_Query_3;
CREATE VIEW Q2_Query_3 AS 
    SELECT cast(numMaxWinner AS FLOAT) / cast(dataCount AS FLOAT) AS percentMaxContributions
    FROM MaxPartyWinners, PartyDataCount;

