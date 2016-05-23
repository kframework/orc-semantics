// Copyright (c) 2012-2014 K Team. All Rights Reserved.
require "ccid.k"
require "pcid.k"
require "extras.k"

module MY_BUILTINS
	//@ This module just imports my own builtin types and functions
  imports CCID-SYNTAX-HOOKS
  imports PCID-SYNTAX-HOOKS
  imports CCID-HOOKS
  imports PCID-HOOKS
  imports EXTRAS
endmodule

