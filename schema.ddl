-- Use for re-importing
DROP SCHEMA IF EXISTS CanadianElections CASCADE;
CREATE SCHEMA CanadianElections;
SET SEARCH_PATH TO CanadianElections;

-- An election candidate.
-- CID is the candidate's unique ID
-- party is the political party the candidate is associated with
-- candidateName is the full name of the candidate
-- riding is the name of the riding from which results are pulled from
CREATE TABLE Candidate (
	CID INT,
	party TEXT NOT NULL,
	candidateName TEXT NOT NULL,
	riding TEXT NOT NULL,
	PRIMARY KEY (CID)
);

-- An election.
-- EID is the election's unique ID
-- electionDate is the date the election took place
CREATE TABLE Election (
	EID INT,
	electionDate TIMESTAMP NOT NULL,
	PRIMARY KEY (EID)
);

-- A person or institution that has made a financial contribution.
-- conID is the unique ID of the contributor
-- contributorName is the full name of the contributor
-- province is the province where contributor lives
-- postalCode is the postal code whre contributor lives
CREATE TABLE Contributor (
	conID INT, 
	contributorName TEXT NOT NULL,
	province TEXT NOT NULL,
	postalCode TEXT NOT NULL,
	PRIMARY KEY (conID)
);

-- An election result.
-- CID is the ID of candidate's whose results are considered
-- EID is the ID of the election where candidate received the votes
-- votes is the number of total votes candidate received during the election
-- incumbent indicates whether candidate was an incumbent during the election
-- leader indicates whether candidate was a leader of their respective party
CREATE TABLE ElectionResult (
	CID INT,
	EID INT,
	votes INT NOT NULL,
	incumbent BOOLEAN NOT NULL,
	leader BOOLEAN NOT NULL,
	PRIMARY KEY (CID, EID),
	FOREIGN KEY (CID) REFERENCES Candidate(CID),
	FOREIGN KEY (EID) REFERENCES Election(EID)
);

-- A financial contribution to a political party.
-- PCID is the unique ID of the party contribution
-- conID is the ID of the contributor who made the contribution
-- party is the name of the party that received the contribution
-- contributionDate is the date the contribution was made
-- amount is the dollar amount of the contribution
CREATE TABLE PartyContribution (
	PCID INT, 
	conID INT, 
	party TEXT NOT NULL,
	contributionDate TIMESTAMP NOT NULL,
	amount FLOAT NOT NULL,
	PRIMARY KEY (PCID),
	FOREIGN KEY (conID) REFERENCES Contributor(conID)
);

-- A financial contribution to a particular candidate.
-- CCID is the unique ID of the candidate contribution
-- conID is the ID of the contributor who made the contribution
-- CID is the ID of the candidate that received the contribution
-- contributionDate is the date the contribution was made
-- amount is the dollar amount of the contribution
CREATE TABLE CandidateContribution (
	CCID INT, 
	conID INT, 
	CID INT,
	contributionDate TIMESTAMP NOT NULL,
	amount FLOAT NOT NULL,
	PRIMARY KEY (CCID),
	FOREIGN KEY (conID) REFERENCES Contributor(conID),
	FOREIGN KEY (CID) REFERENCES Candidate(CID)
);