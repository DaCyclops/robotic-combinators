-- Times per second (max 60) that robotic combinators will update values.
--  Each combinator type has separate figures for: 
--    - Fast Update Processes (main values of provided stats)
--    - Slow Update Processes (calculating stats that could cause lag)
-- Feel free to tweak these figures 

rc_polling_rate_network = 12
rc_polling_rate_network_slow = 3
rc_polling_rate_personal = 12
rc_polling_rate_personal_slow = 4
rc_polling_rate_local = 20
rc_polling_rate_local_slow = 10