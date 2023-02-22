# RenPlaytime (22.02.2023)

# By Rorkh (RenTar)
# https://github.com/Rorkh

playtime_config:
    type: data

    translation:
        you_played: You have played for

        seconds: seconds
        minutes: minutes
        hours: hours

        total: in total
        session: in this session

playtime_message:
    type: task
    definitions: time|unit|type

    script:
        - define translation <script[playtime_config].data_key[translation]>
        - narrate "<&f>Playtime <&8>><&f> <[translation].get[you_played]> <&3><[time]> <[translation].get[<[unit]>]><&f> <[translation].get[<[type]>]>."

sync_time:
    type: task
    script:
        # Get online time (session time) from join
        - define session_time <util.time_now.epoch_millis.add[<player.flag[join_time].mul[-1]>]>
        - flag <player> session_time:<[session_time]>

        # Add session time to total playtime
        - define play_time_now <player.flag[play_time].add[<[session_time]>]>
        - flag <player> play_time_now:<[play_time_now]>

playtime_events:
    type: world
    debug: false

    events:
        on player joins bukkit_priority:low:
            # Set join time
            - flag <player> join_time:<util.time_now.epoch_millis>

            # Create play time flag if not exists
            - if !<player.flag[play_time].exists>:
                - flag <player> play_time:0
        on player quits:
            # Sync time on exit
            - inject sync_time
            - flag <player> play_time:<[play_time_now]>

playtime_command:
    type: command
    name: playtime
    description: Playtime.
    usage: /playtime
    tab completions:
        1: total|session
    script:
        # Update time flag
        - inject sync_time

        # Determine type (session/total)
        - define type total

        - if <context.args.get[1].equals[session]>:
            - define type session

        # Time to seconds
        - if <[type].equals[total]>:
            - define time <[play_time_now].div[1000].round_down>
        - else:
            - define time <[session_time].div[1000].round_down>

        # Determine unit and narrate
        - if <[time]> < 60:
            - run playtime_message def:<[time]>|seconds|<[type]>
        - else:
            - define time <[time].div[60].round_down>

            - if <[time]> < 60:
                - run playtime_message def:<[time]>|minutes|<[type]>
            - else:
                - define time <[time].div[60].round_down>
                - run playtime_message def:<[time]>|hours|<[type]>