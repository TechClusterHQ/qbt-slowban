# qbt-slowban

Docker mod for the [linuxserver.io qbittorrent container](https://docs.linuxserver.io/images/docker-qbittorrent) that automatically bans peers who are leeching off of you slowly over a period of time. Banning slow leechers can help increase your HDD's lifespan and reduce the load put on it as random reads (which happen when someone leeches different parts of the file from you) are reduced.

## Considerations before using

- Check if your tracker forbids banning too many peers
- Banning too many peers might result in you unable to download some files if the only seeders have been banned. Additionally, if the speed at which you could upload to them changes after they're banned, you won't know and keep them banned

In general, use this script at your own risk and carefully think about what might happen if you use it.

## Installation

First, enable the option "Bypass authentication for clients on localhost" in the qBittorrent settings under the "Web UI" tab

Add the following environment variables to your qBittorrent container:
- `WEBUI_PORT=8080`: If it doesn't exist already and you changed the port from the default 8080
- `DOCKER_MODS=ghcr.io/techclusterhq/qbt-slowban:main`
- `SLOWBAN_THRESHOLD_TIME=180`: In seconds
- `SLOWBAN_MIN_SPEED=`: If a peer downloads from you slower than this speed for the specified timeframe, they will be banned (in B/s)
- `SLOWBAN_POLL_INTERVAL=10`: How often to check the peer stats. the default value should be fine

> [!NOTE]  
> If you are already using another docker mod with your qBittorrent container you have to combine both into one DOCKER_MODS variable, seperated by a pipe:
> ```yaml
> DOCKER_MODS=ghcr.io/techclusterhq/qbt-slowban:main|ghcr.io/techclusterhq/qbt-portchecker:main
> ```

Start the stack again and check if the script starts banning slow peers. Feel free to open a [GitHub issue](https://github.com/TechClusterHQ/qbt-slowban/issues) or DM me on Discord (username `app.py`).

## Unbanning peers automatically on a schedule

This helps making sure that false positives don't cause much harm because all banned peers are unbanned frequently.\
Note: This will unban all peers, including those not banned by qbt-slowban. Refer to the option below to specify peers that should be banned permanently.

Make sure to have set the TZ environment variable to your timezone, refer to [this list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List) for possible values.

You need a cron schedule that specifies when all peers should be unbanned, https://crontab.guru is a useful tool for this.\
Common examples ([more](https://crontab.guru/examples.html)):
- `0 0 * * *` run at midnight every day (recommended)
- `0 0 * * 1` run at midnight only on mondays
- `0 0 1 * *` run at midnight on the first day of the month

Set it as an environment variable:
```yaml
- SLOWBAN_CLEAR_PERIODICALLY=0 0 * * *
```

If you want specific peers to be permanently banned, even when the list is cleared, you can specify them using the following environment variable (comma-seperated, no spaces inbetween):
```yaml
- SLOWBAN_BANNED_PEERS=1.1.1.1,8.8.8.8
```

## Unbanning peers manually

In the qBittorrent Web Interface, edit the IPs in the "Manually banned IP addresses" textbox in the "Connection" tab.

## Debugging

Debug/testing variables:
- `SLOWBAN_LOG_LEVEL=DEBUG`: Show all logs
- `SLOWBAN_STUB_REQUESTS=true`: Don't ban anyone but rather log a message when someone is under the threshold (requires loglevel debug)