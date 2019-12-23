classdef test < matlab.unittest.TestCase
%%input all the varlable for the test    
properties
        D
        R
        T
        G
        p
        peaksnr
        tolerenz
        value_tolerenz
        m_verify_damp = 'validate_dmap.m'
        m_disparitymap_census = 'disparitymap_census.m'
        m_disparity_map_GM ='disparitymap_GM'
        m_challenge = 'challenge.m'
end
    %%input all the depedently variable product in the methods function
    properties(Dependent) 
           X_variables
           X_tolerenz
           X_toolbox 
    end
    %%check the variables D,R,T bigger than 0
    methods(Test)
            function X_variables = check_variables(input) 
                     expSolution = all(input.D(:)>0)&&all(input.R(:)>0)&&all(input.T(:)>0);
                     if expSolution == 1
                        X_variables = ('alle geforderten variablen in der Datei challenge.m sind nicht leer bzw. grosser als Null');
                        disp(X_variables);
                     else
                        X_variables = ('es gibt geforderten variablen in der Datei nicht leer bzw. grosserals Null');
                        disp(X_variables);
                     end
            end   
    end
     %%check the tolerenz is withwin the threshold 0,01
     methods(Test)
            function X_tolerenz = check_psnr(input)
                     if input.tolerenz < 0.01
                     X_tolerenz = ('das Ergebnis innerhalb einer angemessenen Toleranz liegt');
                     else 
                     X_tolerenz = ('das Ergebnis innerhalb einer angemessenen Toleranz liegt');
                     end
                     disp(X_tolerenz);
            end
     end
     %%the function check the Disparity-function if the function use the toolbox
     methods(Test)
             function X_toolbox = check_toolbox(Static)
                      [~,pList_disparitymap_census] = matlab.codetools.requiredFilesAndProducts(Static.m_disparitymap_census);
                      [~,pList_disparity_map_GM ] = matlab.codetools.requiredFilesAndProducts(Static.m_disparity_map_GM );
                      [~,pList_verify_damp] = matlab.codetools.requiredFilesAndProducts(Static.m_verify_damp);
                      [~,pList_challenge] = matlab.codetools.requiredFilesAndProducts(Static.m_challenge);
                      flag = size({pList_disparitymap_census}',1)>1||size({pList_disparity_map_GM}',1)>1||size({pList_verify_damp}',1)>1||size({pList_challenge}',1)>1;
                      if flag == 1
                      X_toolbox = ['die verwendete toolbox ist'... 
                      {pList_disparitymap_census.Name},{pList_disparity_map_GM.Name},{pList_verify_damp.Name}];
                      disp(X_toolbox);
                      else
                      X_toolbox = ['Toolbox wurde nicht verwendete'];
                      disp(X_toolbox);
                      end
             end
     end
end


