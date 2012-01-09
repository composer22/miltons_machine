module MiltonsMachine
  module Core
    module Constants

      # The 'A' above middle 'C'

      MIDDLE_A = 440    # in hz

      # 20 hz really, but we nudge it since low frequencies can be "felt" between 4-16 hz and heard (by some humans)
      # as low as 12 hz

      MINIMUM_HUMAN_HEARING = 4

      # 20 kHz really, but we nudge it a bit to 1/2 the standard sampling rate of recordings (44.1 kHz)

      MAXIMUM_HUMAN_HEARING = 22050

      # 1200/log(2)

      CENTS_CONVERSION = 3986.31371

      # used for converting cents to a frequency interval in the octave and is equal to 2 ** (1/1200)

      TWELVE_TET_CONVERSION = 1.00057779

    end
  end
end
