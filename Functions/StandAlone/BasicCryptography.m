%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                          BasicCryptography                            %%
%%                    Last update: December 21, 2021                     %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Function based on Bill Higley's method for encrypting data, with the
% option of using capital letters and all special characters. Please note,
% however, that this function has an extremely low level of security.
%% - Input -
% data = 1*N (char or double) : unencrypted or crypted data
%% - Option -
% 'Key' : Decrypts data using the supplied key
%% - Outputs -
% data = 1*N char : unencrypted or crypted data
% key = 1*N double : decryption key
%% - Examples -
% Encryption
%   >> [data,key]=BasicCryptography('1234')
%       -> data='*;Tz'
%       -> key=[-7,9,33,70]
% Decryption
%   >> data=BasicCryptography('*;Tz','Key',[-7,9,33,70])
%       -> data='1234';
%% -

function [data,key]=BasicCryptography(data,varargin)

% #. Inputs
p=inputParser;
addOptional(p,'Key',[]);
parse(p,varargin{:});
key=p.Results.Key;

% #. Convert to char if input is numeric
if isscalar(data)
    data=num2str(data);
end

% #. Processing
if isempty(key)
    % #.#. No key -> Generate key and encrypted data
    % Each character has an index. However, below a certain index, all
    % characters are identical. For each character, the index value that
    % can be subtracted or added to encrypt is therefore different
    % (otherwise application will be overjective and the decrypted
    % variable will not be found).
    limitLow=33-double(data); limitSup=126-double(data);
    key=round((limitSup-limitLow).*rand(1,numel(data))+limitLow); % Key for decrypting
    data=char(double(data)+key); % Encrypted data
else
    % #.#. Key -> Decrypt data
    data=char(double(data)-key); % Decryption
end

end