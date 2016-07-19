function [nr,zr,s21c] = LotsSmallLines_RandomUC_COMSOL_13Feb15...
    (param,plotFlag,NbLines,freq)

ModelUtil.remove('Model');
ModelUtil.clear

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');
ModelUtil.showProgress(true);

model.param.set('L', '0.2[m]');
model.param.set('H', '0.05[m]');
model.param.set('D', '0.05[m]');

model.modelNode.create('mod1');
model.modelNode('mod1').name('Model 1');

model.geom.create('geom1', 2);

% Import lines (Abel)
for line = 1:NbLines  
    xa = param(line,1); ya = param(line,2); 
    xb = param(line,3); yb = param(line,4);
    lineName = ['b' num2str(line)];
    model.geom('geom1').feature.create(lineName, 'BezierPolygon');
    model.geom('geom1').feature(lineName).set('p', {num2str(xa) num2str(xb); ...
        num2str(ya) num2str(yb)});
    model.geom('geom1').feature(lineName).set('w', {'1' '1'});
    model.geom('geom1').feature(lineName).set('degree', {'1'});
end
model.geom('geom1').feature.create('r2', 'Rectangle');
model.geom('geom1').feature.create('r3', 'Rectangle');
model.geom('geom1').feature('r2').set('base', 'center');
model.geom('geom1').feature('r2').set('pos', {'0' '0'});
model.geom('geom1').feature('r2').set('size', {'L' '0.05'});
model.geom('geom1').feature('r3').set('size', {'D' 'H'});
model.geom('geom1').feature('r3').set('base', 'center');
model.geom('geom1').run;
mphgeom(model)

% Define selections (Abel)
model.selection.create('acpr_dst_pc1', 'Explicit');
leftPort = mphselectbox(model,'geom1',[-0.11 -0.09; -0.03 0.03],'boundary');
rightPort = mphselectbox(model,'geom1',[0.11 0.09; -0.03 0.03],'boundary');
upBd = mphselectbox(model,'geom1',[-0.11 0.11; 0.0251 0.0249],'boundary');
lwBd = mphselectbox(model,'geom1',[-0.11 0.11; -0.0251 -0.0249],'boundary');
inSt = mphselectbox(model,'geom1',[-0.0249 0.0249; -0.0249 0.0249],'boundary');
% 
model.variable.create('var1');
model.variable('var1').model('mod1');
model.variable('var1').set('p_i', 'exp(-1i*acpr.k*x)[Pa]');
model.variable('var1').set('s11', 'intop1(acpr.p_t-p_i)/intop1(p_i)');
model.variable('var1').set('s11p', 's11*exp(i*acpr.k*(L-D))');
model.variable('var1').set('s21', 'intop2(acpr.p_t)/intop1(p_i)');
model.variable('var1').set('s21p', 's21*exp(i*acpr.k*(L-D))');

model.material.create('mat1');

model.cpl.create('intop1', 'Integration', 'geom1');
model.cpl.create('intop2', 'Integration', 'geom1');
model.cpl('intop1').selection.geom('geom1', 1);
model.cpl('intop1').selection.set(leftPort);
model.cpl('intop2').selection.geom('geom1', 1);
model.cpl('intop2').selection.set(rightPort);

model.physics.create('acpr', 'PressureAcoustics', 'geom1');
model.physics('acpr').feature.create('pwr1', 'PlaneWaveRadiation', 1);
model.physics('acpr').feature('pwr1').selection.set([leftPort rightPort]);
model.physics('acpr').feature('pwr1').feature.create('ipf1', 'IncidentPressureField', 1);
model.physics('acpr').feature('pwr1').feature('ipf1').selection.set([leftPort]);
model.physics('acpr').feature.create('pc1', 'PeriodicCondition', 1);
model.physics('acpr').feature('pc1').selection.set([upBd lwBd]);
model.physics('acpr').feature.create('ishb1', 'InteriorSoundHard', 1);
model.physics('acpr').feature('ishb1').selection.set([inSt]);

model.mesh.create('mesh1', 'geom1');
model.mesh('mesh1').feature.create('ftri1', 'FreeTri');

model.variable('var1').name('Variables 1a');

model.material('mat1').propertyGroup('def').set('density', '1.25*(1-0.005i)');
model.material('mat1').propertyGroup('def').set('soundspeed', '343/(1-0.005i)');

model.cpl('intop1').name('Integration 1a');
model.cpl('intop2').name('Integration 2a');

model.physics('acpr').feature('pwr1').feature('ipf1').set('pamp', '1');

model.mesh('mesh1').feature('size').set('hauto', 1);
model.mesh('mesh1').run;

model.study.create('std2');
model.study('std2').feature.create('freq', 'Frequency');

model.sol.create('sol1');
model.sol('sol1').study('std2');
model.sol('sol1').attach('std2');
model.sol('sol1').feature.create('st1', 'StudyStep');
model.sol('sol1').feature.create('v1', 'Variables');
model.sol('sol1').feature.create('s1', 'Stationary');
model.sol('sol1').feature('s1').feature.create('p1', 'Parametric');
model.sol('sol1').feature('s1').feature.create('fc1', 'FullyCoupled');
model.sol('sol1').feature('s1').feature.remove('fcDef');

model.study('std2').feature('freq').set('initstudyhide', 'on');
model.study('std2').feature('freq').set('initsolhide', 'on');
model.study('std2').feature('freq').set('notstudyhide', 'on');
model.study('std2').feature('freq').set('notsolhide', 'on');

model.result.numerical.create('pev1', 'EvalPoint');
model.result.numerical.create('pev2', 'EvalPoint');
model.result.numerical('pev1').selection.set([2]);
model.result.numerical('pev1').set('probetag', 'none');
model.result.numerical('pev2').selection.set([2]);
model.result.numerical('pev2').set('probetag', 'none');
model.result.create('pg1', 'PlotGroup2D');
model.result('pg1').feature.create('surf1', 'Surface');

model.study('std2').feature('freq').set('plist', num2str(freq));
model.study('std2').feature('freq').set('preusesol', 'yes');

model.sol('sol1').attach('std2');
model.sol('sol1').feature('st1').name('Compile Equations: Frequency Domain');
model.sol('sol1').feature('st1').set('studystep', 'freq');
model.sol('sol1').feature('v1').set('control', 'freq');
model.sol('sol1').feature('s1').set('control', 'freq');
model.sol('sol1').feature('s1').feature('p1').set('plistarr', {num2str(freq)});
model.sol('sol1').feature('s1').feature('p1').set('preusesol', 'yes');
model.sol('sol1').feature('s1').feature('p1').set('pcontinuationmode', 'no');
model.sol('sol1').feature('s1').feature('p1').set('pname', {'freq'});
model.sol('sol1').feature('s1').feature('fc1').set('termonres', 'off');
model.sol('sol1').runAll;

model.result.numerical('pev1').name('s11p');
model.result.numerical('pev1').set('expr', 's11p');
model.result.numerical('pev1').set('descr', 's11p');
model.result.numerical('pev1').set('unit', '');
model.result.numerical('pev2').name('s21p');
model.result.numerical('pev2').set('expr', 's21p');
model.result.numerical('pev2').set('descr', 's21p');
model.result.numerical('pev2').set('unit', '');
model.result('pg1').run;
model.result('pg1').feature('surf1').set('rangecoloractive', 'on');
model.result('pg1').feature('surf1').set('rangecolormin', '-2');
model.result('pg1').feature('surf1').set('rangecolormax', '2');
model.result('pg1').run;

% Extract result data (Abel)
s11r = model.result.numerical('pev1').getReal();
s11i = model.result.numerical('pev1').getImag();
s11c = s11r+1i*s11i; 
s21r = model.result.numerical('pev2').getReal();
s21i = model.result.numerical('pev2').getImag();
s21c = s21r+1i*s21i; 
% Calculate parameters (Abel)
freq1 = freq;
kwl = 2*pi*freq1/343;
D = mphglobal(model,'D');
nr = 1/kwl/D*(acos((1-(s11c)^2+(s21c)^2)/2/s21c)-2*pi*0);
zr = sqrt(((1+s11c)^2-(s21c)^2)/((1-s11c)^2-(s21c)^2));
% Display result (Abel)
if plotFlag == 'y', mphplot(model,'pg1'); end
disp(['nr = ' num2str(nr)]);
disp(['zr = ' num2str(zr)]);

