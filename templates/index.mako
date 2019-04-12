<%!
  from templates.utils import numword
  from templates.data.games import Game, SegmentReference
%>
<%inherit file="include/base.mako" />
<%namespace file="include/elements.mako" name="el" />
<%namespace file="include/statistics.mako" name="stats" />

<%block name="head">
<title>Главная страница | ${config['title']}</title>
</%block>

<%block name="content">
<p>Этот сайт содержит архив стримов и чата Twitch-канала <a href="https://www.twitch.tv/blackufa/">BlackUFA</a>. Источником записей служат официальные каналы <a href="https://www.youtube.com/user/BlackSilverUFA">BlackSilverUFA</a> и <a href="https://www.youtube.com/user/BlackSilverChannel">BlackSilverChannel</a>. В редких случаях запись не попадает ни на один из этих каналов, поэтому в архив вносятся неофициальные записи с <a href="/missing.html#youtube">YouTube</a> или из <a href="/missing.html#vk">ВКонтакте</a>.</p>

<p>Чат сохраняется в формате субтитров ASS сразу после завершения трансляции при помощи скрипта <a href="https://github.com/TheDrHax/Twitch-Chat-Downloader">Twitch-Chat-Downloader</a>. Все субтитры попадают в <a href="https://github.com/${config['github']['user']}/${config['github']['repo']}/tree/${config['github']['pages']}/chats">репозиторий на GitHub</a>, откуда их можно скачать и подключить к практически любому плееру.</p>

<p>Для просмотра стримов не нужно что-то скачивать или устанавливать: в сайт встроен HTML5-плеер <a href="https://github.com/sampotts/plyr">Plyr</a> и движок субтитров <a href="https://github.com/Dador/JavascriptSubtitlesOctopus">Subtitles Octopus</a>. Просто выберите серию стримов ниже и наслаждайтесь <img style="margin-bottom: -0.1em;" src="https://static-cdn.jtvnw.net/emoticons/v1/180344/1.0" /> :)</p>

<%stats:statistics />

% for category in categories:
  ## Заголовок категории
  <%el:header level="${category['level']}" id="${category['code']}">
    ${category['name']}
  </%el:header>

  ## Описание категории
  % if category.get('description'):
    <p>${category['description']}</p>
  % endif

  <% year = None %>\

  ## Карточки
  <div class="row d-none d-sm-flex">
  % for game in sorted(category['games'], key=lambda k: k.date):
    % if category.get('split_by_year') != False and year is not None and year != game.date.year:
    <div class="col-12"><div class="hr-sect">↓ ${game.date.year} год ↓</div></div>
    % endif
<% year = game.date.year %>\

    % if type(game) == Game:
      <div class="col-sm-6 col-md-4 col-lg-3 col-xl-2 col-card">
        <div class="card">
          <%el:game_link game="${game}">
            <noscript><img class="card-img-top" src="${game.thumbnail()}" /></noscript>
            <img class="card-img-top lazyload" src="/static/images/no-preview.png" data-original="${game.thumbnail()}" />
            <div class="card-img-overlay overlay-transparent-bottom bg-dark text-white">
              ${game['name']}
            </div>
            <div class="card-img-overlay card-badge">
              <span class="badge badge-primary">
                ${numword(game.stream_count(), 'стрим')}
              </span>
            </div>
          </%el:game_link>
        </div>
      </div>
    % elif type(game) == SegmentReference:
      <div class="col-sm-6 col-md-4 col-lg-3 col-xl-2 col-card">
        <div class="card">
          <%el:stream_link game="${game.game}" stream="${game}">
            <noscript><img class="card-img-top" src="${game.thumbnail()}" /></noscript>
            <img class="card-img lazyload" src="/static/images/no-preview.png" data-original="${game.thumbnail()}" />
            <div class="card-img-overlay overlay-transparent-bottom bg-dark text-white">
              ${game['name']}
            </div>
          </%el:stream_link>
        </div>
      </div>
    % endif
  % endfor
  </div>

  <% year = None %>\

  ## Список (для маленьких экранов)
  <ul class="list-group d-sm-none">
  % for game in sorted(category['games'], key=lambda k: k.date):
    % if category.get('split_by_year') != False and year is not None and year != game.date.year:
    <div class="col-12"><div class="hr-sect">↓ ${game.date.year} год ↓</div></div>
    % endif
<% year = game.date.year %>\

    % if type(game) == Game:
      <li class="list-group-item d-flex justify-content-between align-items-center">
        <%el:game_link game="${game}">
          ${game['name']}
        </%el:game_link>

        <span class="badge badge-primary">
          ${numword(game.stream_count(), 'стрим')}
        </span>
      </li>
    % elif type(game) == SegmentReference:
      <li class="list-group-item">
        <%el:stream_link game="${game.game}" stream="${game}">
          ${game['name']}
        </%el:stream_link>
      </li>
    % endif
  % endfor
  </ul>
% endfor
</%block>