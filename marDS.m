
function recon = marDS( sinogram, thetas, nDetectors, dSize, cx, cy, ...
  Nx, Ny, dx, dy, window )

  W = Wavelet;
  mkdir('tmp');

  % determine the sinogram mask
  %recon = ctIRadon( sinogram, thetas, dSize, cx, cy, Nx, Ny, dx, dy, 'Hanning' );
  %metalMask=findMetal(recon,50);
  %sinoMask = ctRadon( metalMask, dx, nDetectors, dSize, thetas );
  %sinoMask = ( sinoMask == 0 );
load 'recon.mat';
load 'sinoMask.mat';

  dOffset = 0;
  dLocs = ( [0:nDetectors-1] - floor(0.5*nDetectors) ) * dSize - dOffset;
  
  % scale sinogram so that max is 1
  sino = sinogram;
  sino=sino-min(sino(:));
  sino = sino / max(sino(:));

  tolerance = 1d-3;
  diff = tolerance + 1;
  nIter = 0;
  
  aIndxs=find(dLocs>=0);
  a=dLocs(aIndxs);

  nA = numel(a);
  nThetas = numel( thetas );


  %dsMatrix = makeDsMatrix( a, thetas, dLocs, thetas );
load 'dsMatrix.mat';

  %lut = makeDsLUT( a(1:2:end), thetas(1:4:end), dLocs(1:2:end), thetas(1:4:end) );
load 'lut.mat';

  % Inverse DS transform
  ids = dsMatrix \ sino(:);
  ids = reshape( ids, nA, nThetas );

junk = causeError()

  % DS transform
  sino = dsMatrix * stIDS(:);
  sino = reshape( sino, nThetas, nDetectors );
  
  sino = dsTransform( stIDS, a(1:2:end), thetas(1:4:end), dLocs(1:2:end), thetas(1:4:end) );
  sino = (sino .* sinoMask) + (stIDS .* (1-sinoMask));
  
  imwrite( sino, ['tmp/sino',num2str(nIter,'%4.4i'),'.jpg'], 'jpeg' );
  
  diff = norm( sino - oldSino );
  disp(['Difference Value: ', num2str(diff) ]);
  
  nIter = nIter + 1;

  recon = ctIRadon( sino, thetas, dSize, cx, cy, Nx, Ny, dx, dy, window );
  
end

