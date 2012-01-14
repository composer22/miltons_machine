#
# == Header File for Loading the Library
#
# Simply a convenient file to include in your source code to load the library
#
# @example  Simple...
#
#   require 'miltons_machine'
#

# Base
require 'miltons_machine/core/constants'
require 'miltons_machine/core/music_math'

# Core classes
require 'miltons_machine/core/forte_set'
require 'miltons_machine/core/forte_dictionary'
require 'miltons_machine/core/tuning'
require 'miltons_machine/core/spectrum'

# Tools
require 'miltons_machine/tools/generator'
require 'miltons_machine/tools/matrix_analyzer'

# Meta
require 'miltons_machine/testing/helpers'
require 'miltons_machine/version'
