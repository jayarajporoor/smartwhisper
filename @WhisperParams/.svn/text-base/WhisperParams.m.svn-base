function obj = WhisperParams(varargin)

% Constructor for WhisperParams class object.
% You must always pass one argument if you want to create a new object.

if nargin==0 % Used when objects are loaded from disk
  obj = init_fields;
  obj = class(obj, 'WhisperParams');
  return;
end

firstArg = varargin{1};
if isa(firstArg, 'WhisperParams') %  used when objects are passed as arguments
  obj = firstArg;
  return;
end

% We must always construct the fields in the same order,
% whether the object is new or loaded from disk.
% Hence we call init_fields to do this.
obj = init_fields; 

% attach class name tag, so we can call member functions to
% do any initial setup
obj = class(obj, 'WhisperParams'); 

% Now the real initialization begins
obj.preamble = [1,1,1,1];
%obj.samples_per_sec = varargin{1};
obj.samples_per_sec = 16000;
obj.cycles_per_sec = 4000;
obj.cycles_per_baud = 20;

obj.cycles_per_bit = obj.cycles_per_baud*2;

obj.samples_per_cycle = ceil(obj.samples_per_sec/obj.cycles_per_sec);
obj.samples_per_bit = ceil(obj.samples_per_cycle * obj.cycles_per_bit);
obj.samples_per_baud = ceil(obj.samples_per_cycle * obj.cycles_per_baud);

obj.bits_per_sec = floor(obj.cycles_per_sec/obj.cycles_per_bit);


%%%%%%%%% 

function obj = init_fields()
% Initialize all fields to dummy values 
obj.preamble = [];
obj.samples_per_sec = [];
obj.cycles_per_sec = [];
obj.cycles_per_baud = [];
obj.cycles_per_bit = [];
obj.samples_per_cycle = [];
obj.samples_per_bit = [];
obj.samples_per_baud = [];
obj.bits_per_sec = [];


