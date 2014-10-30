function result = HammingDistance(v1, v2)

len = min(length(v1), length(v2));
distance = 0;
for i = 1 : len
    if (v1(i) ~= v2(i))
        distance = distance + 1;
    end    
end

result = distance + abs(length(v1) - length(v2));
