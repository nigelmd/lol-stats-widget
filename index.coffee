apiKey = '' # put your api key here
summonerApiVersion = 'v1.4' # Note the v before the version number
gamesApiVersion = 'v1.3' # Note the v before the version number
staticApiVersion = 'v1.2' # Note the v before the version number
ddragonApiVersion = '5.2.1'


summonerName = '' # put your summoner name here

regionName = 'euw'

command: "curl -s 'https://#{regionName}.api.pvp.net/api/lol/euw/#{summonerApiVersion}/summoner/by-name/#{summonerName}?api_key=#{apiKey}'"

refreshFrequency: 600000

style: """
  top: 100px
  left: 25px
  color: #fff
  font-family: Helvetica Neue

  .container
    width: 750px
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
  $.each data, (index, element) ->
    appData["profileId"] = element.id
    $(domEl).find('.profile-icon')
      .html("<img src='http://ddragon.leagueoflegends.com/cdn/#{appData["ddragonApiVersion"]}/img/profileicon/"+element.profileIconId+".png'>")
    $(domEl)
      .find('.profile-id')
      .html("Profile Id: "+ element.id)
    $(domEl)
      .find('.profile-name')
      .html("Profile Name: "+ element.name)
      .data("profile-name", element.name)
    $(domEl)
      .find('.profile-level')
      .html("Profile Level: "+ element.summonerLevel)
      .data("profile-level", element.summonerLevel)

  @run("curl -s 'https://euw.api.pvp.net/api/lol/#{appData["regionName"]}/#{appData["gamesApiVersion"]}/game/by-summoner/#{appData["profileId"]}/recent?api_key=#{appData["apiKey"]}'",(error, output) ->
    data = JSON.parse(output)
    mostRecent = data.games[0]
    appData["championId"] = mostRecent.championId
    matchResult = if mostRecent.stats.win then "WIN" else "LOSS"

    $(domEl)
      .find('.match-type')
      .html("Match type: " + mostRecent.gameMode + " " + mostRecent.subType)
    $(domEl)
      .find('.champions-killed')
      .html("Kills: " + mostRecent.stats.championsKilled)
    $(domEl)
      .find('.deaths')
      .html("Deaths: " + mostRecent.stats.numDeaths)
    $(domEl)
      .find('.assists')
      .html("Assists: " + mostRecent.stats.assists)
    $(domEl)
      .find('.win')
      .html("Match Result: " + matchResult)
  )

  setTimeout ( ->
    getChampionData("curl -s 'https://global.api.pvp.net/api/lol/static-data/#{appData["regionName"]}/#{appData["staticApiVersion"]}/champion/#{appData["championId"]}?champData=image&api_key=#{appData["apiKey"]}'",(error, output) ->
      data = JSON.parse(output)
      $(domEl)
        .find('.champion-icon')
        .html("<img src='http://ddragon.leagueoflegends.com/cdn/#{appData["ddragonApiVersion"]}/img/champion/"+data.image.full+"'>")
    )
  ), 2000


appData:
  'apiKey': @apiKey
  'summonerApiVersion': @summonerApiVersion
  'ddragonApiVersion': @ddragonApiVersion
  'gamesApiVersion': @gamesApiVersion
  'staticApiVersion': @staticApiVersion
  'regionName': @regionName
  'summonerName': @summonerName
  'profileId': 'profile-id'
  'championId': 'champion-id'
