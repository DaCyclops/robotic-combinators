-- Times per second (max 60) that robotic combinators will update values.
--  Each combinator type has seperate figures for: 
--    - Fast Update Processes (main values of provided stats)
--    - Slow Update Processes (calulating stats that could cause lag)
-- Feel free to tweak these figures 

rc_polling_rate_network = 20
rc_polling_rate_network_slow = 10
rc_polling_rate_personal = 20
rc_polling_rate_personal_slow = 5
rc_polling_rate_local = 30
rc_polling_rate_local_slow = 10