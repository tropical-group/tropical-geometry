module Geometry.Vertex 

(isExtremeVertex, isOneFace)

where


import Numeric.LinearProgramming
import Data.List ((\\))
import Debug.Trace
import Util

{- 
    Module that implements functions for the finding of all the extreme vertices in the Newton polyhedron of a polynomial f.
-}


-- | Analizes whether a point in a set is extremal or not.
-- | This function is based on Theorem 2 of the article "Linear Programming Approaches to the Convex Hull Problem in R^m"
isExtremeVertex :: (Num a, Enum a, Real a) => [a] -> [[a]] -> Bool
isExtremeVertex point set = feasibleNNegative objectiveFunc constraintsLeft constraintsRight
    where
        set2 = set \\ [point]
        differences = map (flip (safeZipWith (-)) point) set2
       -- tValues = map (negate.pred.(foldr1 (+))) differences
        sigmaValues = repeat (-1)
        objectiveFunc = (1) : (replicate (length point) 0)
        constraintsLeft = ((map.map) realToFrac $ (zipWith (:) sigmaValues differences))
        constraintsRight = (replicate (length set2) 0)


feasibleNNegative :: [Double] -> [[Double]] -> [Double] -> Bool
feasibleNNegative objectiveFunc constraintsLeft constraintsRight = feasNOpt resultLP
-- trace ("SIMPLEX: " ++ show resultLP ) 
    where
        problem = Minimize objectiveFunc
        constraints = Dense $ safeZipWith (:<=:) constraintsLeft constraintsRight
        bounds = (1 :>=: (-1)) :  map (:&: (-1,1)) [2..(length objectiveFunc)]
        resultLP = exact problem constraints bounds
        feasNOpt (Optimal (optVal, _)) = optVal < 0
        feasNOpt _ = False



-- | Decides whether two points form a 1-face or not.
-- | -- | This function is based on LP5 of the article "Linear Programming Approaches to the Convex Hull Problem in R^m"

isOneFace :: (Num a, Enum a, Real a) => [a] -> [a] -> [[a]] -> Bool
isOneFace xi xj set = feasibleNNegative2 objectiveFunc constraintsLeft constraintsRight
    where
        set2 = set \\ [xi, xj]
        differencesXi = map (flip (safeZipWith (-)) xi) set2  
        differencesXj = map (flip (safeZipWith (-)) xj) set2
        diffXiXj = safeZipWith (-) xi xj
        differences = diffXiXj : (differencesXi ++ differencesXj)
        sigmaValues = 0 : repeat (-1)
        objectiveFunc = 1 : (replicate (length xi) 0)
        constraintsLeft = ((map.map) realToFrac $ zipWith (:) sigmaValues differences)
        constraintsRight = (replicate ((length set2)*2+1) 0)

feasibleNNegative2 :: [Double] -> [[Double]] -> [Double] -> Bool
feasibleNNegative2 objectiveFunc constrLeft@(x:xs) constrRight@(y:ys) = feasNOpt resultLP
-- trace ("SIMPLEX: " ++ show resultLP ) 
    where
        problem = Minimize objectiveFunc
        constraints = Dense $ (x :==: y) : safeZipWith (:<=:) xs ys
        bounds = (1 :>=: (-1)) : map (:&: (-1,1)) [2..(length objectiveFunc)]
        resultLP = exact problem constraints bounds
        feasNOpt (Optimal (optVal, _)) = optVal < 0
        feasNOpt _ = False


