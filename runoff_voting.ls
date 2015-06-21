root = exports ? this

votes_in_order = (line) ->
  output = []
  for x in ['First choice', 'Second choice', 'Third choice', 'Fourth choice', 'Fifth choice']
    output.push line[x]
  return output

get_vote = (line) ->
  for vote in votes_in_order(line)
    if vote == ''
      continue
    if root.blacklist[vote]?
      continue
    return vote
  return null

get_remaining_candidates = ->
  output = []
  for x in root.all_candidates
    if not root.blacklist[x]?
      output.push x
  return output

list_candidate_votes = (csv) ->
  output = {}
  for candidate in get_remaining_candidates()
    output[candidate] = 0
  for line in csv
    vote = get_vote line
    if not vote?
      continue
    #if not output[vote]?
    #  output[vote] = 0
    output[vote] += 1
  return output

get_candidate_with_fewest_votes = (candidate_votes) ->
  min_votes = Number.MAX_VALUE
  candidate_with_fewest_votes = null
  for candidate,votes of candidate_votes
    if votes < min_votes
      min_votes = votes
      candidate_with_fewest_votes = candidate
  return candidate_with_fewest_votes

main = ->
  loader = require 'csv-load-sync'
  csv = loader 'Name voting.csv'
  root.all_candidates = []
  all_candidates_set = {}
  for line in csv
    for x in votes_in_order(line)
      if x? and x != '' and not all_candidates_set[x]?
        all_candidates_set[x] = true
        root.all_candidates.push x
  root.blacklist = {}
  round_num = 1
  while true
    console.log '============================'
    console.log 'Round ' + round_num
    console.log 'Remaining candidates:'
    console.log JSON.stringify get_remaining_candidates()
    candidate_votes = list_candidate_votes(csv)
    console.log 'Votes:'
    console.log JSON.stringify candidate_votes
    eliminated_candidate = get_candidate_with_fewest_votes(candidate_votes)
    console.log 'Candidate eliminated: ' + eliminated_candidate
    root.blacklist[eliminated_candidate] = true
    candidate_list = Object.keys candidate_votes
    round_num += 1
    if candidate_list.length <= 1
      console.log 'Winner: ' + candidate_list[0]
      return

main()
