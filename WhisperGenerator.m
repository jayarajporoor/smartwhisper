function result = WhisperGenerator(params)

params

hash = WhisperGetHash();

data = [params.preamble, hash];

amplitude = 100;

cycles_per_bit = params.cycles_per_bit;

samples_per_cycle = params.samples_per_cycle;
samples_per_bit = params.samples_per_bit;
samples_per_baud = params.samples_per_baud;

total_bits = length(data);

total_samples = total_bits * cycles_per_bit * samples_per_cycle;

bit = 1;
m = 1;
scale(1,1)=0;
scale(1,2)=1;
scale(2,1)=1;
scale(2,2)=0;
code=1;

for n = 1 : total_samples
    samples(n) = scale(data(bit)+1,code)*(1+sin(2*pi*n/samples_per_cycle))*amplitude;    
    m=m+1;
    if ( m > samples_per_baud)
        code = 2;
    end
    if ( m > samples_per_bit) 
        code = 1;
        m = 1;
        bit=bit+1;
    end
end

result = samples;