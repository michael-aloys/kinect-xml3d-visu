%
%    Visualization of a Human using Kinect and XML3D - Prototype 2
%    Copyright (C) 2015  Michael Hedderich, Magdalena Kaiser, Dushyant Mehta, Guillermo Reyes
%
%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License along
%    with this program; if not, write to the Free Software Foundation, Inc.,
%    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
%

%
%  Authors: Michael Hedderich, Magdalena Kaiser, Dushyant Mehta, Guillermo Reyes
%  Last modified: 2015/09/24
%


%Properly retarget kinect to blender. This assumes that both skeletons have
%the same topology. If the skeletons have a different topology, then the
%code would have to be appropriately adopted

%Kinect Bind Pose (from the pre scaling era)
% kr = reshape([-0.00721196 0.998547 0.0429852 0.031673 -0.00722121 0.998554 0.0429837 0.0314582 -0.00894414 0.999079 0.0278447 0.0314115 -0.0111328 0.999407 0.00792807 0.0316019 0.770992 -0.636443 -0.0119238 -0.0192048 -0.5077 0.27302 0.754186 0.31449 -0.0235387 -0.317393 0.825244 0.466562 -0.0588708 -0.362718 0.816998 0.444391 0.793079 0.605902 0.0589841 0.0207283 0.416785 0.286871 0.814639 -0.283476 0.817007 0.496931 0.063811 -0.28546 0.793506 0.523474 0.0607943 -0.304348 0.691372 0.693662 -0.114283 -0.166664 0.676416 0.0293626 0.728139 -0.106829 0.611582 0.0629128 0.785037 -0.0756811 -0.676087 0.697712 -0.13112 0.197262 0.713808 -0.00222183 -0.685414 -0.143808 -0.541004 0.0201676 0.835821 0.09117],4,[])';
% kt = reshape([1.02332 -0.950074 8.06719 1.02332 -0.950074 8.06719 0.996191 0.62798 8.20245 0.973595 1.7776 8.26588 0.973595 1.7776 8.26588 0.144642 1.61791 8.25369 -0.801653 0.795609 8.37013 -1.63022 0.397119 7.77122 0.973595 1.7776 8.26588 1.89287 1.52356 8.36595 2.83457 0.617194 8.6764 3.78621 0.232304 8.22434 1.02332 -0.950074 8.06719 1.40146 -0.94273 7.90749 1.80978 -2.98216 7.69473 1.02332 -0.950074 8.06719 0.610679 -0.926275 7.85909 0.166831 -3.05044 7.41092],3,[])';

%Kinect Bind Pose (From bottom and top half scaled era)
kr = reshape([0.0197099 0.993244 0.0853031 0.0761646 0.017806 0.994694 0.0857207 0.0540336 0.0157379 0.99682 0.0715981 0.0312303 0.0150976 0.998047 0.0520975 0.0309885 0.800887 -0.594392 -0.0202739 -0.0697559 -0.384745 0.239168 0.826027 0.335336 -0.0689545 -0.234805 0.780373 0.575439 -0.138309 -0.346042 0.719905 0.585544 0.806411 0.586218 0.0717608 -0.0299912 0.39624 0.165907 0.831823 -0.351481 0.0110975 -0.317219 0.784514 -0.532716 0.0707682 -0.421511 0.719833 -0.546955 0.689737 0.700696 -0.0500852 -0.175438 0.640475 -0.0439498 0.758955 -0.108849 0.725502 -0.00830066 0.680125 -0.104915 -0.662845 0.689522 -0.147448 0.251903 0.748937 -0.00387319 -0.650181 -0.127843 0.709821 -0.0103242 -0.698076 -0.0934706],4,[])';
kt = reshape([-0.00626966 -0.338279 2.36447 -0.00626966 -0.338279 2.36447 0.00242422 -0.0110315 2.42179 0.00892442 0.227982 2.45651 0.00892442 0.227982 2.45651 -0.174376 0.173532 2.43969 -0.358894 0.00834786 2.47396 -0.549973 -0.0418589 2.37556 0.00892442 0.227982 2.45651 0.191487 0.168222 2.46339 0.362849 0.00124894 2.46278 0.546153 -0.0498786 2.35009 -0.00626966 -0.338279 2.36447 0.0731707 -0.334637 2.33834 0.122139 -0.771799 2.24567 -0.00626966 -0.338279 2.36447 -0.0855362 -0.330936 2.31376 -0.162117 -0.761499 2.23077],3,[])';
figure(1)

% kt = reshape([-0.179624 -0.338699 2.30052 -0.179624 -0.338699 2.30052 -0.168481 -0.00497218 2.35332 -0.159431 0.238599 2.38401 -0.159431 0.238599 2.38401 -0.367645 0.213351 2.36301 -0.62792 0.208417 2.38092 -0.857559 0.204423 2.35906 -0.159431 0.238599 2.38401 0.0419826 0.205168 2.41621 0.287501 0.164979 2.41428 0.514243 0.158069 2.38875 -0.179624 -0.338699 2.30052 -0.0845639 -0.336964 2.28057 -0.0339347 -0.741071 2.19169 -0.179624 -0.338699 2.30052 -0.268606 -0.328983 2.24271 -0.333651 -0.732325 2.16806],3,[])';
% kr = reshape([0.0244394 0.991589 0.0762558 0.101682 0.0229981 0.993329 0.0767028 0.0829779 0.022428 0.995822 0.061279 0.0638741 0.0229728 0.99686 0.0414403 0.0634483 0.74824 -0.659565 -0.00535514 -0.0712922 -0.484918 0.509994 0.523745 0.480055 0.713163 -0.697078 -0.00740636 -0.0736571 0.718217 -0.687073 0.026694 -0.106686 0.755186 0.647226 0.102793 0.0150508 0.254077 0.211055 0.71848 -0.612117 0.714027 0.680484 0.072802 -0.14767 0.699312 0.688102 0.0328788 -0.190781 0.700575 0.701403 -0.0163103 -0.130243 0.618912 -0.0458086 0.775668 -0.114842 0.69016 0.0255539 0.713058 -0.120726 -0.656122 0.695196 -0.154645 0.249582 0.766996 -0.00347025 -0.630319 -0.120013 -0.705522 0.0189446 0.702963 0.0878771],4,[])';
% figure(2)

kr = [kr(:,4) kr(:,1:3)];
kr = quat2dcm(kr);

for i = 1:18
    kr(:,:,i) = kr(:,:,i)';
end
tx = [kr reshape(kt', 3, 1, [])];  % Making a transformation matrix by appending translation ( This becomes rotate then translate)
tx = [tx; repmat([0 0 0 1], [1, 1, 18])];

%Blender bind pose
blender_armature = reshape([0.9998230934143066 -0.011634159833192825 -0.014780988916754723 0 0.010375719517469406 -0.31433674693107605 0.9492550492286682 0 -0.015689987689256668 -0.9492404460906982 -0.31416043639183044 0 0.004828260745853186 0.08338608592748642 2.8885509967803955 1 0.9999917149543762 0.0033629760146141052 0.0023005849216133356 0 -0.002254405291751027 -0.013670280575752258 0.999904215335846 0 0.0033941033761948347 -0.9999010562896729 -0.013662589713931084 0 0.006597084924578667 0.029798926785588264 3.0503768920898438 1 0.9999690055847168 0.003550903173163533 0.007034334819763899 0 -0.007094975560903549 0.01736566051840782 0.9998242259025574 0 0.0034281229600310326 -0.9998430609703064 0.017390312626957893 0 0.004278154578059912 0.0157373808324337 4.078899383544922 1 0.9994764924049377 0.020307190716266632 0.02518799528479576 0 -0.021283911541104317 -0.17366662621498108 0.9845746755599976 0 0.024368252605199814 -0.9845952987670898 -0.17314349114894867 0 0.001009031431749463 0.028678297996520996 4.823969841003418 1 0.0708465725183487 -0.9881691336631775 0.13602611422538757 0 0.9903231859207153 0.05336606875061989 -0.12811142206192017 0 0.11933636665344238 0.1437862068414688 0.9823874831199646 0 0.001009031431749463 0.028678297996520996 4.823969841003418 1 -0.6669164299964905 -0.10577580332756042 -0.7375872135162354 0 0.7423222064971924 -0.008419835940003395 -0.6699907779693604 0 0.06465832144021988 -0.9943549036979675 0.08413482457399368 0 0.605187714099884 0.06123591959476471 4.7458109855651855 1 -0.49901705980300903 0.006418716162443161 -0.8665689826011658 0 0.8274227976799011 -0.29371052980422974 -0.4786505401134491 0 -0.2575926184654236 -0.955873429775238 0.14125534892082214 0 1.273151159286499 0.053659532219171524 4.1429338455200195 1 0.3137814700603485 0.9355522990226746 -0.16212370991706848 0 0.7120476961135864 -0.34481000900268555 -0.6116330623626709 0 -0.6281160116195679 0.07647906988859177 -0.7743527293205261 0 1.870356559753418 -0.15833066403865814 3.7974600791931152 1 0.07084657996892929 0.9881690740585327 -0.13602623343467712 0 -0.9903231263160706 0.05336599797010422 -0.128111332654953 0 -0.1193363294005394 0.1437862366437912 0.9823874235153198 0 -0.001009032828733325 0.028678297996520996 4.823969841003418 1 -0.6669163703918457 0.10577594488859177 0.7375870943069458 0 -0.7423222064971924 -0.008419877849519253 -0.6699906587600708 0 -0.06465842574834824 -0.9943547248840332 0.08413504809141159 0 -0.6051875948905945 0.061235927045345306 4.7458109855651855 1 -0.49901703000068665 -0.006418587174266577 0.8665688633918762 0 -0.8274227976799011 -0.29371047019958496 -0.47865039110183716 0 0.25759246945381165 -0.9558732509613037 0.14125549793243408 0 -1.2731510400772095 0.053659506142139435 4.1429338455200195 1 0.3137812912464142 -0.9355521202087402 0.16212382912635803 0 -0.7120476961135864 -0.344809889793396 -0.6116329431533813 0 0.6281160116195679 0.07647892832756042 -0.7743526101112366 0 -1.8703563213348389 -0.1583305448293686 3.7974605560302734 1 0.14287608861923218 -0.24477246403694153 0.9589959979057312 0 -0.9763312935829163 -0.19381187856197357 0.09599065035581589 0 0.16236887872219086 -0.9500125050544739 -0.2666701078414917 0 0.006597084924578667 0.029798926785588264 3.0503768920898438 1 0.9879820942878723 0.02830820344388485 -0.15195490419864655 0 -0.15367385745048523 0.074246846139431 -0.9853286147117615 0 -0.01661069318652153 0.996838390827179 0.0777047872543335 0 -0.27949729561805725 -0.026993712410330772 3.078505039215088 1 0.9871424436569214 -0.007835363037884235 -0.1596517264842987 0 -0.1558029055595398 0.17599232494831085 -0.9719839692115784 0 0.03571328893303871 0.9843607544898987 0.17250871658325195 0 -0.494701623916626 0.0769813135266304 1.6986545324325562 1 0.22618892788887024 0.8661924600601196 -0.44558900594711304 0 0.9740777015686035 -0.20271334052085876 0.1003994569182396 0 -0.0033615753054618835 -0.45674753189086914 -0.8895902633666992 0 0.006597084924578667 0.029798926785588264 3.0503768920898438 1 0.9879820942878723 -0.028308184817433357 0.15195514261722565 0 0.15367408096790314 0.07424657046794891 -0.9853286743164062 0 0.016610559076070786 0.9968384504318237 0.07770460844039917 0 0.27949732542037964 -0.02699374221265316 3.078504800796509 1 0.9871424436569214 0.007835464552044868 0.1596519947052002 0 0.1558031439781189 0.17599207162857056 -0.9719840288162231 0 -0.03571352735161781 0.9843608140945435 0.17250853776931763 0 0.49470189213752747 0.0769808292388916 1.6986546516418457 1 ],4,4,[]);
%Blender armature with offset_matrix
%blender_armature = reshape([0.07189656794071198 -1.2091443124528922e-10 2.2594512372187125e-10 0 3.403583664907117e-11 -4.871830938668609e-8 0.07189657539129257 0 8.548105973060771e-11 -0.07189657539129257 -3.87956617942109e-8 0 1.4182353069713827e-9 0.0000010005157946579857 -7.087602966748818e-7 1 0.07189656794071198 -7.498199283695328e-11 1.73187311713896e-10 0 2.083985588263726e-11 -5.34009778618838e-8 0.07189657539129257 0 1.7197059054563368e-10 -0.07189658284187317 -4.250737362099244e-8 0 8.057931544236396e-10 9.794775905902497e-7 -3.5891909533347643e-7 1 0.07189656794071198 -7.705480697950406e-11 1.4210060905739397e-10 0 1.4095028963434508e-11 -5.3502564156815424e-8 0.07189656794071198 0 1.6736032004693868e-10 -0.07189658284187317 -4.255081265114313e-8 0 -2.3979351837510876e-9 9.899615633912617e-7 -2.1953762541215838e-7 1 0.07189656794071198 1.1786591147533443e-10 2.3326579556837146e-10 0 8.670329731952364e-11 -5.2329173882981195e-8 0.07189656794071198 0 -1.3984338687045295e-10 -0.07189657539129257 -4.129340425151895e-8 0 1.2275116922921825e-8 9.791169759409968e-7 -5.837090384375188e-7 1 0.07189657539129257 -7.127288759178896e-10 -1.4583327434536386e-8 0 1.898610380024479e-9 -4.099218742226185e-8 0.07189659029245377 0 -1.5969815692074008e-8 -0.07189659029245377 -4.0790975930349305e-8 0 -1.0250694515434589e-7 1.2347656763722625e-7 -0.0000012616718549907091 1 0.07189656049013138 -1.6052108975372903e-8 -1.1484513784409955e-8 0 1.839557484117904e-8 -5.155796145572822e-8 0.07189659029245377 0 -2.2547903100189615e-8 -0.07189659774303436 -5.5056965209132613e-8 0 -8.65074753164663e-7 9.250252333004028e-7 -0.0000018873657836593338 1 0.07189656049013138 -1.5713538914496894e-8 -9.314096161006091e-9 0 1.5000686914845573e-8 -5.324992358168856e-8 0.07189659029245377 0 -2.7444229999673553e-8 -0.07189660519361496 -5.1836678949257475e-8 0 -7.151936074478726e-7 0.000001078284981304023 -0.0000022098793124314398 1 0.07189656794071198 -1.9719267996265444e-8 -9.384216070884577e-9 0 1.522271197984537e-8 -5.417453508016479e-8 0.07189660519361496 0 -2.416110511660463e-8 -0.07189660519361496 -5.555805770995903e-8 0 -8.34295462937007e-7 0.0000012245122888998594 -0.000003260988023612299 1 0.07189657539129257 4.849738832746198e-9 2.5688100535603553e-9 0 1.625417356265757e-9 -4.235329598145654e-8 0.07189658284187317 0 9.312374871228712e-9 -0.07189659774303436 -3.81851670283595e-8 0 -7.004133095733778e-8 1.9232213332998072e-7 -0.0000015311359220504528 1 0.07189657539129257 1.0970932606824135e-8 8.926172689882605e-9 0 -1.0696286523170784e-8 -4.644420670274485e-8 0.07189658284187317 0 9.643170706397086e-9 -0.07189659774303436 -4.341617909631168e-8 0 1.2567268470320414e-7 6.013772235746728e-7 -0.0000015159841950662667 1 0.07189656049013138 9.095034947392833e-9 4.521092833442708e-9 0 -1.0615243795086826e-8 -4.791547070226443e-8 0.07189658284187317 0 1.2419858919088256e-8 -0.07189659774303436 -4.005978126997434e-8 0 7.539160407077361e-8 7.002448683124385e-7 -0.0000014267295682657277 1 0.07189656794071198 9.799996369963537e-9 8.771483095415533e-9 0 -5.860844698446499e-9 -5.066887709404e-8 0.07189659029245377 0 1.0356371760167349e-8 -0.07189659774303436 -4.45075549748708e-8 0 4.6602696102127084e-7 9.305637149736867e-7 -0.0000020945744836353697 1 0.07189656049013138 -4.486465643438464e-10 -2.091011586102809e-9 0 -3.662052883157685e-10 -5.2274852890832335e-8 0.07189657539129257 0 -1.0747800427424181e-9 -0.07189657539129257 -4.204742509728021e-8 0 6.56721397263027e-8 9.754213579071802e-7 -5.619338026008336e-7 1 0.07189656049013138 1.5569618483368686e-8 -4.41294639719203e-11 0 -1.059367082945073e-8 -6.65659030119059e-8 0.07189656794071198 0 1.3169766610587885e-8 -0.07189659029245377 -5.771950739585918e-8 0 4.369008479443437e-7 0.0000017122265489888377 -1.4168713846629544e-7 1 0.07189656049013138 1.4373889634100578e-8 -6.312397826668814e-10 0 -1.0706854958186796e-8 -6.69141115849925e-8 0.07189655303955078 0 1.2044981900771745e-8 -0.07189659774303436 -6.214430214868116e-8 0 3.695130885716935e-7 0.0000017448832068112097 -7.919894073893374e-8 1 0.07189657539129257 -4.112461926553124e-9 9.398411826566644e-9 0 -3.6162635108638597e-9 -5.4875108901342173e-8 0.07189658284187317 0 6.346431380421791e-9 -0.07189658284187317 -3.430047001984349e-8 0 1.7843257182903471e-7 0.0000012046085657857475 -7.234087320284743e-7 1 0.07189657539129257 -1.9983760424224783e-8 2.4650685048754895e-8 0 -4.648117890582171e-9 -5.42344444909304e-8 0.07189662009477615 0 2.4082633665045705e-9 -0.07189661264419556 -3.989077157484644e-8 0 1.3782324970179616e-7 0.000001129823544943065 -0.0000023923307708173525 1 0.07189657539129257 -1.868841614793837e-8 2.7794467172270743e-8 0 -4.261442310138364e-9 -5.522934998225537e-8 0.07189659029245377 0 3.018547634070501e-9 -0.07189660519361496 -4.537581332897389e-8 0 1.230806248031513e-7 0.0000010948857607218088 -0.0000017662443951849127 1 ],4,4,[]);
bt = reshape(blender_armature(1:3,4,:), 3, []);

hold off;
clf 
%Plot Blender Skeleton. Comment out the following lines to stop blender
%skeleton from showing
plot3(bt(1,:),bt(2,:),bt(3,:),'ro')
hold on;
plot3(bt(1,7),bt(2,7),bt(3,7),'kv')
for i = 1:18
    origin = [0 0 0 1]';
    x_ax = [0.2 0 0 1]';
    y_ax = [0 0.4 0 1]';
    z_ax = [0 0 0.2 1]';
    origin = blender_armature(:,:,i)*origin;
    x_ax = blender_armature(:,:,i)*x_ax;
    y_ax = blender_armature(:,:,i)*y_ax;
    z_ax = blender_armature(:,:,i)*z_ax;
    plot3([origin(1); y_ax(1)], [origin(2); y_ax(2)], [origin(3); y_ax(3)], 'g', 'LineWidth', 3);
    plot3([origin(1); x_ax(1)], [origin(2); x_ax(2)], [origin(3); x_ax(3)], 'r');
    plot3([origin(1); z_ax(1)], [origin(2); z_ax(2)], [origin(3); z_ax(3)], 'b');


end
%Blender skeleton plotting ends    

%Transformation from kinect to blender. Just use the joint locations to get a global transformation
%Once they are in comparable coordinates, then extablish the relative transformation of bones
%Compute the kinect to blender scale
bl = norm(bt(:,17)-bt(:,18));
R = eye(3,3);
T = zeros(3,1);
trans = kt';
kl = norm(trans(:,17)-trans(:,18));
scale = bl/kl;
trans = scale*trans;

%Plotting scaled kinect skeleton (still in its own coordinate system, not
%rotated to take it to blender armature space
% plot3(trans(1,:),trans(2,:),trans(3,:),'k*')
% plot3(trans(1,7),trans(2,7),trans(3,7),'kv')
% 
% for i = 1:18
%     origin = [0 0 0 1]';
%     x_ax = [0.09 0 0 1]';
%     y_ax = [0 0.15 0 1]';
%     z_ax = [0 0 0.09 1]';
%     origin = [scale*eye(3) zeros(3,1); 0 0 0 1]*tx(:,:,i)*origin;
%     x_ax = [scale*eye(3) zeros(3,1); 0 0 0 1]*tx(:,:,i)*x_ax;
%     y_ax = [scale*eye(3) zeros(3,1); 0 0 0 1]*tx(:,:,i)*y_ax;
%     z_ax =  [scale*eye(3) zeros(3,1); 0 0 0 1]*tx(:,:,i)*z_ax;
%     plot3([origin(1); y_ax(1)], [origin(2); y_ax(2)], [origin(3); y_ax(3)], 'g', 'LineWidth', 3);
%     plot3([origin(1); x_ax(1)], [origin(2); x_ax(2)], [origin(3); x_ax(3)], 'r');
%     plot3([origin(1); z_ax(1)], [origin(2); z_ax(2)], [origin(3); z_ax(3)], 'b');
% 
% end
 axis([-8 5 -5 5 2 9])
 
%Here we compute the global (single) transformation between scaled kinect skeleton and
%blender armature
for i = 1:2
   trans = R*scale*kt' + repmat(T,1,size(trans,2));
  [r,t] = solvepose3(trans, bt);
  tf = [r t; 0 0 0 1]* [R T; 0 0 0 1];
  R = tf(1:3,1:3);
  T = tf(1:3,4);
end
Tx_global = [R T; 0 0 0 1]*[scale*eye(3) zeros(3,1); 0 0 0 1];


transformed_kinect = tx;
for i = 1:18
    transformed_kinect(:,:,i) = Tx_global * tx(:,:,i);
end

%Plot scaled and globally transformed kinect skeleton. All we have done
%until now is aligned our kinect skeleton to the blender armature so that
%we can proceed with computation of the transformations between bones
%(This might be an unnecessary step. Maybe we can directly compute the
%transformation without aligning the two skeletons together, but this
%additional step sure comes in handy for debug purposes)
kt = R*scale*kt'+repmat(T,1,size(kt,1));
view_tx = [0 0 0];
kt = kt + repmat(view_tx',1, 18);
plot3(kt(1,:),kt(2,:),kt(3,:),'go')
plot3(kt(1,7),kt(2,7),kt(3,7),'kv')

y_180 = [cos(pi) 0 sin(pi) 0;
         0   1   0   0;
         -sin(pi) 0 cos(pi) 0;
         0 0 0 1];

for i = 1:18
    origin = [0 0 0 1]';
    x_ax = [0.09 0 0 1]';
    y_ax = [0 0.15 0 1]';
    z_ax = [0 0 0.09 1]';
    origin = transformed_kinect(:,:,i)*origin + [view_tx 0]';
    x_ax = transformed_kinect(:,:,i)*x_ax + [view_tx 0]';
    y_ax = transformed_kinect(:,:,i)*y_ax + [view_tx 0]';
    z_ax = transformed_kinect(:,:,i)*z_ax + [view_tx 0]';
    plot3([origin(1); y_ax(1)], [origin(2); y_ax(2)], [origin(3); y_ax(3)], 'k', 'LineWidth', 3);
    plot3([origin(1); x_ax(1)], [origin(2); x_ax(2)], [origin(3); x_ax(3)], 'r');
    plot3([origin(1); z_ax(1)], [origin(2); z_ax(2)], [origin(3); z_ax(3)], 'b');

end
    
%Compute the mapping between bones
local_kinect_tx = transformed_kinect;
local_blender_tx = blender_armature;
for i = 1:18
    local_mapping(:,:,i) = local_kinect_tx(:,:,i)\local_blender_tx(:,:,i);
    if( i == 7) || (i == 11)
        local_mapping(:,:,i) = y_180 * local_mapping(:,:,i);
    end
end
%%
% % %test cell
%  blah = transformed_kinect;
% % test = reshape(transformed_kinect(1:3,4,:), 3, []);
%  for i = 1:18
%      blah(:,:,i) =  blah(:,:,i) * mapping(:,:,i) ;
%  end
% % test = reshape(blah(1:3,4,:), 3, []);
% % 
% % plot3(test(1,:),test(2,:),test(3,:),'ms')
% plot3(test(1,7),test(2,7),test(3,7),'ko')

%%
%Additional kinect pose for testing
kt = reshape([-0.179624 -0.338699 2.30052 -0.179624 -0.338699 2.30052 -0.168481 -0.00497218 2.35332 -0.159431 0.238599 2.38401 -0.159431 0.238599 2.38401 -0.367645 0.213351 2.36301 -0.62792 0.208417 2.38092 -0.857559 0.204423 2.35906 -0.159431 0.238599 2.38401 0.0419826 0.205168 2.41621 0.287501 0.164979 2.41428 0.514243 0.158069 2.38875 -0.179624 -0.338699 2.30052 -0.0845639 -0.336964 2.28057 -0.0339347 -0.741071 2.19169 -0.179624 -0.338699 2.30052 -0.268606 -0.328983 2.24271 -0.333651 -0.732325 2.16806],3,[])';
kr = reshape([0.0244394 0.991589 0.0762558 0.101682 0.0229981 0.993329 0.0767028 0.0829779 0.022428 0.995822 0.061279 0.0638741 0.0229728 0.99686 0.0414403 0.0634483 0.74824 -0.659565 -0.00535514 -0.0712922 -0.484918 0.509994 0.523745 0.480055 0.713163 -0.697078 -0.00740636 -0.0736571 0.718217 -0.687073 0.026694 -0.106686 0.755186 0.647226 0.102793 0.0150508 0.254077 0.211055 0.71848 -0.612117 0.714027 0.680484 0.072802 -0.14767 0.699312 0.688102 0.0328788 -0.190781 0.700575 0.701403 -0.0163103 -0.130243 0.618912 -0.0458086 0.775668 -0.114842 0.69016 0.0255539 0.713058 -0.120726 -0.656122 0.695196 -0.154645 0.249582 0.766996 -0.00347025 -0.630319 -0.120013 -0.705522 0.0189446 0.702963 0.0878771],4,[])';

kr = [kr(:,4) kr(:,1:3)];
kr = quat2dcm(kr);

for i = 1:18
    kr(:,:,i) = kr(:,:,i)';
end
tx = [kr reshape(kt', 3, 1, [])];  % Making a transformation matrix by appending translation ( This becomes rotate then translate)
tx = [tx; repmat([0 0 0 1], [1, 1, 18])];

transformed_kinect = tx;
for i = 1:18
    transformed_kinect(:,:,i) =  Tx_global * tx(:,:,i) * local_mapping(:,:,i) ;
end

new_kt = reshape(transformed_kinect(1:3,4,:), 3, []);
plot3(new_kt(1,:),new_kt(2,:),new_kt(3,:),'*')
plot3(new_kt(1,7),new_kt(2,7),new_kt(3,7),'kv')
for i = 1:18
    origin = [0 0 0 1]';
    x_ax = [0.2 0 0 1]';
    y_ax = [0 0.4 0 1]';
    z_ax = [0 0 0.2 1]';
    origin = transformed_kinect(:,:,i)*origin;
    x_ax = transformed_kinect(:,:,i)*x_ax;
    y_ax = transformed_kinect(:,:,i)*y_ax;
    z_ax = transformed_kinect(:,:,i)*z_ax;
    plot3([origin(1); y_ax(1)], [origin(2); y_ax(2)], [origin(3); y_ax(3)], 'k', 'LineWidth', 3);
    plot3([origin(1); x_ax(1)], [origin(2); x_ax(2)], [origin(3); x_ax(3)], 'r');
    plot3([origin(1); z_ax(1)], [origin(2); z_ax(2)], [origin(3); z_ax(3)], 'b');

end