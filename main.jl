begin
using Images
f(z,c) = z^2 + c

#generic range generator
#make all complex points
function generate_matrix(quality :: Tuple{Int64,Int64} = (128,128), range :: Tuple{Complex,Complex} = (-2+2im,2-2im))
    local dt = complex(abs(real(range[1]) - real(range[2])) / quality[1], abs(imag(range[1]) - imag(range[2])) / quality[2])
    local _f(x,y) = ( x*real(dt) + 1im * y*imag(dt) )
    local result = [_f(i,j) for i=1:quality[1] for j=1:quality[2]] .+ range[1]
    return result
end

#run the f() function above s times on mtr
function calculate(mtr,s)
    local result = reshape(repeat([s],length(mtr)),width(mtr),height(mtr))
    local z = copy(mtr) * 0im
    for x in 1:s
        z = f.(z,mtr)
        local r = Int.(abs.(z) .< 2)
        result -= r
    end
    return result
end

#array slicer
function subdivide(mtr,sub_index,sub_size)
    local _s = (1  +sub_size * (sub_index[1]-1), 1 .+ sub_size * (sub_index[2]-1))
    local _e = (min(_s[1]+sub_size-1, length(mtr)), min(_s[2]+sub_size-1, width(mtr)))
    return mtr[ _s[1]:_e[1], _s[2]:_e[2] ]
end

#run matrix generate
function generate_fractal(img_size, complex_range,subdiv,iter_count)
    local mtx = reshape(generate_matrix(img_size,complex_range),img_size...)
    local result = Int.(similar(mtx))
    local dt = Int(floor(width(mtx)/subdiv))
    local ranges = []
    for j in 1:subdiv for k in 1:subdiv
        #TODO: change this to not include the calculate() function yet, use it at preperation for gpu computing
        result[1 + (j - 1) * dt : j * dt,1 + (k - 1) * dt : k * dt] = calculate(subdivide(mtx,(j,k),dt),iter_count)
    end
 end
return HSV.(result.*[20] .% 360,1,(result.!=0))
end

"""
arguments:
1: tuple length 2: Interger : image output dimensions
2: tuple length 2: Interger : complex plane range
3: Interger                 : number of subdivisions
4: Interger                 : number of iterations
"""

local image_output = generate_fractal((2^8,2^8),(-2 -2im , 2+2im),3,10)
save("IMAGE_OUTPUT.png",image_output)
image_output
end
