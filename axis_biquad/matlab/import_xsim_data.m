%% Import data from text file
% Script for importing data from the following text file:
%
%    filename: /home/pablo/matlab/data.txt
%
% Auto-generated by MATLAB on 18-Apr-2021 18:49:07

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 2);

% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = " ";

% Specify column names and types
opts.VariableNames = ["output", "Var2"];
opts.SelectedVariableNames = "output";
opts.VariableTypes = ["double", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";

% Specify variable properties
opts = setvaropts(opts, "Var2", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "Var2", "EmptyFieldRule", "auto");
opts = setvaropts(opts, "output", "TrimNonNumeric", true);
opts = setvaropts(opts, "output", "ThousandsSeparator", ",");

% Import the data
tbl = readtable("data_q1.txt", opts);

%% Convert to output type
output = tbl.output;

%% Clear temporary variables
clear opts tbl