apiKey = '' # put your api key here
summonerApiVersion = 'v1.4' # Note the v before the version number
gamesApiVersion = 'v1.3' # Note the v before the version number
staticApiVersion = 'v3' # Note the v before the version number

summonerName = 'xcrucifier' # put your summoner name here

regionName = 'na1'

command: ("curl -s 'https://#{regionName}.api.riotgames.com/lol/summoner/v3/summoners/by-name/#{summonerName}?api_key=#{apiKey}'")

refreshFrequency: 600000

style: """
  top: 100px
  left: 25px
  color: #fff
  font-family: Helvetica Neue

  .container
    width: 770px
    /* background: rgba(204, 108, 115, 0.61) */
    height: 200px
    clear: both

  .widget-title
    position: absolute
    left: 0
    top: -14px
    font-size: 10px
    font-weight: 500

  .profile-icon
    float: left
    padding: 0 5px 5px 0

  .profile-stats
    display: inline-block
    float: left

  .profile-stats div
    padding: 5px 5px 5px 5px

  .section-title
    display: inline-block
    padding: 5px 5px 5px 5px

  .champion-icon
    float: left
    padding: 0 5px 5px 0

  .match-stats
    display: inline-block

  .match-stats div
    padding: 2px 2px 5px 5px

  .clear
    clear: both

"""


render: -> """
  <div class="container">
    <div class="widget-title">Lol Stats</div>
    <div class="profile-icon">
        <img class="profile-image">
    </div>
    <div class="profile-stats">
        <div class="profile-id"></div>
        <div class="profile-name"></div>
        <div class="profile-level"></div>
    </div>
    <div class="champion-icon">
        <img class="champion-image">
    </div>
    <div class="match-stats">
        <div class="match-type"></div>
        <div class="champions-killed"></div>
        <div class="deaths"></div>
        <div class="assists"></div>
        <div class="win"></div>
    </div>
  </div>
"""

update: (output, domEl) ->
  appData = @appData
  data  = JSON.parse(output)
  getChampionData = @run
  getMatchData = @run
  appData["profileId"] = data.accountId
  $(domEl).find('.profile-icon')
    .html("<img src='http://ddragon.leagueoflegends.com/cdn/6.24.1/img/profileicon/"+data.profileIconId+".png'>")
  $(domEl)
    .find('.profile-id')
    .html("Profile Id: "+ data.accountId)
  $(domEl)
    .find('.profile-name')
    .html("Profile Name: "+ data.name)
    .data("profile-name", data.name)
  $(domEl)
    .find('.profile-level')
    .html("Profile Level: "+ data.summonerLevel)
    .data("profile-level", data.summonerLevel)

  #console.log(apiKey)
  #gameId = null
  mostRecent = null
  matchResult = null
  gameMode = null
  gameType = null
  championsKilled = null
  deaths = null
  assists = null
  championId = null
  @run("curl -s 'https://na1.api.riotgames.com/lol/match/v3/matchlists/by-account/#{appData["profileId"]}?api_key=#{apiKey}'",(error, output) ->
    data = JSON.parse(output)
    mostRecent = data.matches[0]
    appData["gameId"] = mostRecent.gameId
    this.gameId = mostRecent.gameId
    appData["championId"] = championId = mostRecent.champion
  )

  setTimeout ( ->
    getMatchData("curl -s 'https://na1.api.riotgames.com/lol/match/v3/matches/#{gameId}?api_key=#{apiKey}'", (error, output) ->
      #console.log(gameId)
      data = JSON.parse(output)
      #console.log(data)
      gameMode = data.gameMode
      gameType = data.gameType
      participantId = null
      $.each data.participantIdentities, (index, participant) ->
        #console.log(participant)
        if participant.player.accountId == appData["profileId"]
          participantId = participant.participantId
          #console.log(participantId)

      $.each data.participants, (index, participant) ->
        #console.log(participant)
        if participant.participantId == participantId
          championsKilled = participant.stats.kills
          deaths = participant.stats.deaths
          assists = participant.stats.assists
          matchResult = if participant.stats.win then "WIN" else "LOSS"

      $(domEl)
        .find('.match-type')
        .html("Match type: " + gameMode + " " + gameType)
      $(domEl)
        .find('.champions-killed')
        .html("Kills: " + championsKilled)
      $(domEl)
        .find('.deaths')
        .html("Deaths: " + deaths)
      $(domEl)
        .find('.assists')
        .html("Assists: " + assists)
      $(domEl)
        .find('.win')
        .html("Match Result: " + matchResult)
    )
  ), 2000

  #console.log(championId)
  setTimeout ( ->
    getChampionData("curl -s 'https://na1.api.riotgames.com/lol/static-data/v3/champions/#{championId}?champData=image&api_key=#{apiKey}'" ,(error, output) ->
      data = JSON.parse(output)
      $(domEl)
        .find('.champion-icon')
        .html("<img src='http://ddragon.leagueoflegends.com/cdn/6.24.1/img/champion/"+data.image.full+"'>")
    )
  ), 2000


appData:
  'apiKey': @apiKey
  'summonerApiVersion': @summonerApiVersion
  'gamesApiVersion': @gamesApiVersion
  'staticApiVersion': @staticApiVersion
  'regionName': @regionName
  'summonerName': @summonerName
  'profileId': 'profile-id'
  'championId': 'champion-id'
  'gameId': 'game-id'
