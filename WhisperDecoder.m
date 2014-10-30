
function result = WhisperDecoder(data, params)

preamble=params.preamble;
frame_data_len = length(WhisperGetHash)

samples_per_sec=params.samples_per_sec;
cycles_per_sec=params.cycles_per_sec;

samples_per_bit = params.samples_per_bit;
samples_per_baud = params.samples_per_baud;

data_len = length(data)

j  = 1;

fft_frame_size = ceil(samples_per_baud/2)
delta = ceil(fft_frame_size/60)
hertz_per_point = ceil(samples_per_sec/fft_frame_size)
delta_hertz = 600;
n_carrier = floor(cycles_per_sec/hertz_per_point)
n_delta = floor(delta_hertz/hertz_per_point)

for i = 1:delta:data_len-fft_frame_size
    f = abs(fft(data(i:i+fft_frame_size)));
    res(j) = 0;
    for k=n_carrier-n_delta:1:n_carrier+n_delta
        res(j) = res(j) + f(k);
    end
    res(j) = res(j)/(n_delta*2+1);
    j=j+1;
end

%filter parameters:
fft_samples_per_baud = samples_per_baud/delta
fft_samples_per_bit = samples_per_bit/delta
fft_cycles_per_sec = cycles_per_sec/delta
fft_sampling_rate = samples_per_sec/delta

Hd = WhisperLoPass();

res = Hd.filter(res);

threshold = sum(res)/length(res)
empirical_threshold_factor = 1/4;
threshold = threshold*empirical_threshold_factor;

%remove leading/trailing near-zero values
i = 1;
DELETE_MARKER = -99;
while i <= length(res)
    if(res(i) > threshold)
        break;
    else
        res(i)=DELETE_MARKER;
    end
    i = i + 1;
end

i = length(res);

while i >= 1
    if(res(i) > threshold)
        break;
    else
        res(i) = DELETE_MARKER;
    end
    i = i - 1;
end

j = 1;
for i = 1 : length(res)
    if(res(i) ~= DELETE_MARKER)
        res1(j) = res(i);
        j = j + 1;
    end
end

res = res1;

%compute threshold once more
threshold = sum(res)/length(res)
empirical_threshold_factor = 3/4;
threshold = threshold*empirical_threshold_factor;

prev = 0;

for i = 1 : length(res)
    if res(i) > threshold
        thresholded_res(i) = 1;
    else
        thresholded_res(i) = 0;
    end
end

if(thresholded_res(1) == 0)
    counting_low = true;
else
    counting_low = false;
end
count=1;
j=1;

for i = 2: length(thresholded_res)
    if(counting_low)
        if(thresholded_res(i) == 0)
            count=count+1;
        else
            counted_res(j) = -count;
            j=j+1;
            count = 1;
            counting_low = false;
        end
    else
        if(thresholded_res(i) == 1)
            count = count + 1;
        else
            counted_res(j) = count;
            j=j+1;
            count = 1;
            counting_low=true;
        end
    end
end

%eliminate initial lows and short spikes
%merge adjacent lows and adjacent highs

%note: 3 is an arbitrary factor
count_threshold = ceil(fft_samples_per_baud/3)

j = 1;
leading_zeros= true;

for i = 1: length(counted_res)

    if(counted_res(i) < -count_threshold)
        if(~leading_zeros && counted_res(i) < count_threshold)
            if((j > 1) && (processed_res(j-1) < 0))
                processed_res(j-1) = processed_res(j-1) + counted_res(i);%merge
            else
                processed_res(j) = counted_res(i);                
                j = j + 1;
            end
        end            
    elseif(counted_res(i) > count_threshold)
        leading_zeros = false;
        if((j > 1) && (processed_res(j-1) > 0))
            processed_res(j-1) = processed_res(j-1) + counted_res(i);%merge
        else
            processed_res(j) = counted_res(i);
            j = j + 1;
        end
    end                    
end

data_idx = 0;

%high_count = count_threshold;
%low_count = -count_threshold;

for i = 1:length(processed_res)-length(preamble)
    %look for preamble
    if(  (processed_res(i  ) >  count_threshold) && ...
         (processed_res(i+1) < -count_threshold) && ...
         (processed_res(i+2) >  count_threshold) && ...
         (processed_res(i+3) < -count_threshold) && ...       
         (processed_res(i+4) >  count_threshold) && ...
         (processed_res(i+5) < -count_threshold) && ...
         (processed_res(i+6) >  count_threshold) && ...
         (processed_res(i+7) < -count_threshold)    ...
         )
         high_count= (processed_res(i) + processed_res(i+2) + processed_res(i+4) + processed_res(i+6))/4;
         high_count = (high_count*3)/4;
         %can't consider the last low-counter since next low may be clubbed in
         %with it
         low_count = (processed_res(i+1) + processed_res(i+3) + processed_res(i+5))/3;
         low_count = (low_count*3)/4;
         %remove 1 zero from the last low-counter
         processed_res(i+7) = processed_res(i+7) - low_count;
         data_idx = i+7;
         break;
    end
end

if(data_idx == 0)
    result = processed_res;
    return
end

i = data_idx;
j = 1;

%result = processed_res(data_idx:length(processed_res));
%return;

%add a low at the end - just in case last high has no matchez low
%if that's not the case, this additional low will be ignored anyway

processed_res(length(processed_res)+1) = (low_count-1);

%high_count
%low_count
%processed_res(data_idx:length(processed_res))

bits(1)=-1; %for error return in case we didn't get any frame

while ( i < length(processed_res)  )
    if ( (processed_res(i) > high_count) && (processed_res(i+1) < low_count) )
        bits(j) = 1;
        j = j + 1;
        if( processed_res(i+1) < 2*low_count)
            i = i + 1;
        else
            i = i + 2;
        end
    elseif( (processed_res(i) < low_count) && (processed_res(i+1) > high_count) )
        bits(j) = 0;
        j = j + 1;
        if( processed_res(i+1) > 2*high_count)
            i = i + 1;
        else
            i = i + 2;
        end        
    else
        i = i + 1;
    end

    if(j > frame_data_len)
        break;
    end    
end

result = bits;
