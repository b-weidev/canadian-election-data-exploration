import pandas as pd
import sys

if __name__ == '__main__':

    # List of files
    files = ['CAND_DATA.csv', 'PARTY_DATA.csv']

    # List of rows to skip
    party_skip = []
    cand_skip = []
    for i in range(217797):
        if i % 74 != 0:
            party_skip.append(i)
    for i in range(108650):
        if i % 36 != 0:
            cand_skip.append(i)

    # Dataframes
    # main_df = pd.concat([pd.read_csv(f, error_bad_lines=False) for f in files])  
    party_df = pd.read_csv('PARTY_DATA.csv', error_bad_lines=False, skiprows=party_skip)
    cand_df = pd.read_csv('CAND_DATA.csv', error_bad_lines=False, skiprows=cand_skip)
    candidates_df = pd.read_csv('candidates.csv', error_bad_lines=False, encoding_errors='replace')

    candidate_dict = {}
    # Candidate
    for index, row in candidates_df.iterrows():
        if row['candidateName'] not in candidate_dict:
            candidate_dict[row['candidateName']] = row['CID']


    # Clean up punctuation ',' signs
    for index, row in party_df.iterrows():
        if (',' in str(row['Contributor first name'])) or (',' in str(row['Contributor last name'])):
            party_df.drop(index, inplace=True)

    for index, row in cand_df.iterrows():
        if (',' in str(row['Contributor first name'])) or (',' in str(row['Contributor last name'])):
            cand_df.drop(index, inplace=True)

    main_df = pd.concat([party_df, cand_df])

    # Contributor dictionary (con_name : id)
    con_dict = {}

    # New dataframes
    """
    contributor_data = {'conID':[], 'contributorName':[], 'province':[], 'postalCode':[]}
    party_data = {'PCID':[], 'conID':[], 'party':[], 'contributionDate':[], 'amount':[]}
    cand_data = {'CCID':[], 'conID':[], 'CID':[], 'contributionDate':[], 'amount':[]}
    contributor_df = pd.DataFrame(contributor_data)
    party_df = pd.DataFrame(party_data)
    cand_df = pd.DataFrame(cand_data)
    """

    # Inserting into contributor dataframe
    i = 0
    dicts_1 = {'conID':[], 'contributorName':[], 'province':[], 'postalCode':[]}
    for index, row in main_df.iterrows():
        contributor_name = str(row['Contributor first name']) + ' ' + str(row['Contributor last name'])
        if contributor_name not in con_dict:
            # Insert into dictionary
            con_dict[contributor_name] = i
            # Insert into dataframe
            dicts_1.get('conID').append(i)
            dicts_1.get('contributorName').append(contributor_name)
            dicts_1.get('province').append(row['Contributor Province'])
            dicts_1.get('postalCode').append(row['Contributor Postal code'])
        i += 1

    # Inserting into party dataframe
    i = 1000
    dicts_2 = {'PCID':[], 'conID':[], 'party':[], 'contributionDate':[], 'amount':[]}
    for index, row in party_df.iterrows():
        # Insert into 
        contributor_name = str(row['Contributor first name']) + ' ' + str(row['Contributor last name'])
        dicts_2.get('PCID').append(i)
        dicts_2.get('conID').append(con_dict.get(contributor_name))
        dicts_2.get('party').append(row['Political Party of Recipient'])
        dicts_2.get('contributionDate').append(row['Fiscal/Election date'])
        dicts_2.get('amount').append(row['Monetary amount'])
        i += 1

    # Inserting into candidate dataframe
    i = 2000
    dicts_3 = {'CCID':[], 'conID':[], 'CID':[], 'contributionDate':[], 'amount':[]}
    for index, row in cand_df.iterrows():
        candidate_name = str(row['Recipient first name']) + ' ' + str(row['Recipient last name'])
        if candidate_name in candidate_dict:
            dicts_3.get('CCID').append(i)
            # Insert into 
            contributor_name = str(row['Contributor first name']) + ' ' + str(row['Contributor last name'])
            dicts_3.get('conID').append(con_dict.get(contributor_name))
            dicts_3.get('CID').append(candidate_dict.get(candidate_name))
            dicts_3.get('contributionDate').append(row['Fiscal/Election date'])
            dicts_3.get('amount').append(row['Monetary amount'])
            i += 1
    
    # Get contributor CSV
    if sys.argv[1] == '0':
        # print('conID,contributorName,province,postalCode')
        for j in range(len(dicts_1.get('conID'))):
            insert_str = str(dicts_1.get('conID')[j]) + ',' + str(dicts_1.get('contributorName')[j]) + ',' + str(dicts_1.get('province')[j]) + ',' + str(dicts_1.get('postalCode')[j])
            print(insert_str)

    # Get party CSV
    if sys.argv[1] == '1':
        # print('PCID,conID,party,contributionDate,amount')
        for j in range(len(dicts_2.get('PCID'))):
            insert_str = str(dicts_2.get('PCID')[j]) + ',' + str(dicts_2.get('conID')[j]) + ',' + str(dicts_2.get('party')[j]) + ',' + str(dicts_2.get('contributionDate')[j]) + ',' + str(dicts_2.get('amount')[j])
            print(insert_str)

    # Get candidate CSV
    if sys.argv[1] == '2':
        # print('CCID,conID,CID,contributionDate,amount')
        for j in range(len(dicts_3.get('CCID'))):
            insert_str = str(dicts_3.get('CCID')[j]) + ',' + str(dicts_3.get('conID')[j]) + ',' + str(dicts_3.get('CID')[j]) + ',' + str(dicts_3.get('contributionDate')[j]) + ',' + str(dicts_3.get('amount')[j])
            print(insert_str)