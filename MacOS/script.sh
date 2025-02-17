#!/bin/bash

system_profiler SPDisplaysDataType  | grep -E 'Display Serial Number' | grep -Eo ': .{10}' | tr -d : | tr -d ' 'j

