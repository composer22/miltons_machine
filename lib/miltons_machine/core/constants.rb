module MiltonsMachine
  module Core
    module Constants

      MIN_HUMAN_HEARING = 10     # 20 hz really, but we nudge it a bit, as some people are moles
      MAX_HUMAN_HEARING = 26000  # 20 kHz really, but we nudge it a bit, as some people are bats and feel the music

      # Some commonly known just-intonation scales...or use your own!
      # TODO load this from a file into a singleton so we can add to our collection externally and save memory

      JUST_INTONATION_RATIOS = {
        #        16/15        9/8      6/5  5/4    4/3         45/32    3/2  8/5  5/3         9/5  15/8     2/1
        ptolemy: [1.06666667, 1.12500, 1.2, 1.25,  1.33333333, 1.40625, 1.5, 1.6, 1.66666667, 1.8, 1.87500, 2.0],

        #                 16/15       9/8      6/5  5/4    4/3         45/32    3/2  8/5  5/3         16/9
        five_limit_sym1: [1.06666667, 1.12500, 1.2, 1.25, 1.33333333, 1.40625, 1.5, 1.6, 1.66666667, 1.77777778,
        #                 15/8     2/1
                          1.87500, 2.0],

        #                 16/15       10/9        6/5  5/4    4/3        45/32    3/2  8/5  5/3         9/5  15/8
        five_limit_sym2: [1.06666667, 1.11111111, 1.2, 1.25, 1.33333333, 1.40625, 1.5, 1.6, 1.66666667, 1.8, 1.87500,
        #                 2/1
                          2.0],

        # eq to ptolemy   16/15       9/8      6/5  5/4    4/3         45/32    3/2  8/5  5/3         9/5  15/8     2/1
        five_limit_asym: [1.06666667, 1.12500, 1.2, 1.25,  1.33333333, 1.40625, 1.5, 1.6, 1.66666667, 1.8, 1.87500, 2.0],

        #             256/243     9/8      32/27       81/64      4/3         1024/729    729/512     3/2  128/81
        pythagorean: [1.05349794, 1.12500, 1.18518519, 1.265625,  1.33333333, 1.40466392, 1.42382812, 1.5, 1.58024691,
        #             27/16   16/9        243/128  2/1
                      1.6875, 1.77777778, 1.87500, 2.0],

        #        25/24	      10/9	      9/8	     32/27	     6/5	5/4	  4/3	        25/18	      45/32	   3/2
        zarlino: [1.04166667, 1.11111111, 1.12500, 1.18518519, 1.2, 1.25, 1.33333333, 1.38888889, 1.40625, 1.5,
        #        25/16	 5/3	        16/9	        9/5	 15/8	    2/1
                 1.5625, 1.66666667,  1.77777778,   1.8, 1.87500, 2.0]
      }
    end
  end
end
