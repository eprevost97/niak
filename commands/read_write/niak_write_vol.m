function [] = niak_write_minc(vol,hdr)

% Write a 3D or 3D+t dataset into a file
%
% SYNTAX:
% [FLAG_ERR,err_msg] = niak_write_vol(vol,hdr)
%
% INPUTS:
% VOL          (3D or 4D array) a 3D or 3D+t dataset
%
% HDR           (structure) a header structure (usually modified from the 
%               output of niak_read_vol). The following fields are of
%               particular importance :
%
%               HDR.FILE_NAME   (string or cell of strings) the name(s) of 
%                   the file that will be written.
%               HDR.TYPE   (string, default 'minc2') the output format (either
%                   'minc1' or 'minc2').
%
%               The following subfields are optional :
%               HDR.INFO.PRECISION      (string, default 'float') the
%                   precision for writting data ('int', 'float' or
%                   'double').
%               HDR.INFO.VOXEL_SIZE     (vector 1*3, default [1 1 1]) the
%                   size of voxels along each spatial dimension in the same
%                   order as in vol.
%               HDR.INFO.TR     (double, default 1) the time between two
%                   volumes (in second)
%               HDR.MAT (2D array 4*4, default identity) an affine transform from voxel to
%                   world space.
%               HDR.DIMENSION_ORDER (string, default 'xyz') describes the dimensions of
%                  vol. Letter 'x' is for 'left to right, 'y' for
%                  'posterior to anterior', 'z' for 'ventral to dorsal' and
%                  't' is time. Example : 'xzyt' means that dimension 1 of 
%                   vol is 'x', dimension 2 is 'z', etc.
%               HDR.HISTORY (string, default '') history of the operations applied to
%                  the data.
%                  
%               HDR.DETAILS (structure, default struct()) This field
%                  contains some format specific information, but is not
%                  necessary to write a file. If present, the information
%                  will be inserted in the new file. Note that the fields
%                  of HDR.INFO override HDR.DETAILS. See NIAK_WRITE_MINC
%                  for more information under the minc format.
%
% OUTPUTS:
% Case 1: HDR.FILE_NAME is a string.
% The data is written in a file called HDR.FILE_NAME in HDR.TYPE format.
%
% Case 2: HDR.FILE_NAME is a cell of strings.
% The number of file names has to correspond to the fourth dimension of
% VOL. One file will be written for each volume VOL(:,:,:,i) in the file
% HDR.FILE_NAME{i};
%
% Case 3: HDR.FILE_NAME is a string, ending by '_'.
% One file will be written for each volume VOL(:,:,:,i) in the file
% [HDR.FILE_NAME 000i]. The '000i' part meaning that i is converted to a
% string and padded with '0' to reach at least four digits.
% 
% COMMENTS:
%
% SEE ALSO:
% niak_read_header_minc, niak_read_minc, niak_read_vol, niak_read_vol
%
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : medical imaging, I/O, reader, minc


% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

try 
    file_name = hdr.file_name;
catch
    error('niak:write_vol','Please specify a file name in hdr.file_name.\n')
end

if iscell(file_name)
    
    %% Case 2: a cell of strings for multiple files
    nb_f = length(file_name);
    if size(vol,4)~= nb_f
        warning('The number of files in hdr.file_name does not correspond to size(vol,4)! Try to proceed anyway...')
    end
    
    hdr2 = hdr;
    
    for num_f = 1:nb_f
        hdr2.file_name = hdr.file_name{num_f};
        niak_write_vol(vol(:,:,:,num_f),hdr2);
        if num_f == 1
            warning('off','niak:default')
        end
    end
    warning('on','niak:default')
    
elseif ischar(file_name)
    
    if strcmp(file_name(end),'_')
        %% Case 3 : A string ending by '_'
        
        nt = size(vol,4);
        nb_digits = max(4,ceil(log10(nt)));
        
        try
            type_f = hdr.type;
        catch
            error('niak:write_vol','Please specify a file format in hdr.type.\n')
        end
        
        switch type_f
            case {'minc1','minc2'} % That's a minc file
                ext_f = '.mnc';
            otherwise
                error('niak:write_vol','%s : unrecognized file format\n',type_f);
        end
        
        base_name = hdr.file_name;
        for num_f = 1:nt
            file_names = cat(2,base_name,repmat('0',1,nb_digits-length(num2str(num_f))),num2str(num_f),ext_f);
            hdr.file_name = file_names;
            if num_f > 1
                warning('off','niak:default')
            end
            niak_write_vol(vol(:,:,:,num_f),hdr);
        end
        warning('on','niak:default')
    else
        %% Case 1 : a regular string       
        try
            type_f = hdr.type;
        catch
            error('niak:write_vol','Please specify a file format in hdr.type.\n')
        end
        
        switch type_f
            case {'minc1','minc2'} % That's a minc file
                niak_write_minc(vol,hdr);
            otherwise
                error('niak:write_vol','%s : unrecognized file format\n',type_f);
        end
        
    end
end