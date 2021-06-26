{-# LANGUAGE OverloadedStrings #-}

module Simplify.LiftStrictness where

import Types.SourceAbstractSyntax (SeqSortOp(..))
import Types.CoreAbstractSyntax (FSig(..), FTerm(..), FPattern (..)
                                ,Strictness(..))
import Types.TargetAbstractSyntax hiding (FPattern(..))

import Data.Text (pack)
import CCO.Component

lift_strictness :: Component CBSFile CBSFile
lift_strictness = component (return . lCBSFile)

lCBSFile :: CBSFile -> CBSFile
lCBSFile cbsf = doToFuncons lFSpec cbsf

lFSpec :: FunconSpec -> FunconSpec
lFSpec spec@(FRules nm sig mcs rs ss) = case sig of  
  FLazy               -> spec
  FNullary            -> spec
  FStrict             -> FRules nm FLazy mcs rs ss'
    where ss' = steprule : ss
          steprule = FStepRule step [Left premise]
          step = FStep  [PAnnotated (PSeqVar "V*" StarOp) 
                          (TSortSeq (TSortSeq (TName "values") QuestionMarkOp) StarOp)
                        ,PMetaVar "X"
                        ,PSeqVar "Y*" StarOp]
                        (TApp (pack nm) [TVar "V*", TVar "X'", TVar "Y*"])
                        [] [] [] [] [] []
          premise = FPremiseStep (TVar "X") [PMetaVar "X'"] [] [] [] [] [] []
{- moved to TargetToIML
          rewrule = FRewriteRule [PSeqVar "X*" StarOp] 
                      (Just (TApp (pack nm) [TVar "Y*"])) [cond]
             where cond = SCPatternMatch (TVar "X*") (PSeqVar "Y*" StarOp) -}
  FPartiallyLazy ann mseqvar -> FRules nm FLazy mcs rs ss'
    where ss'       = map mkRule ruleKeys ++ seqvarRule ++ ss
          ruleKeys  = map fst $ filter ((Strict ==) . snd) keys
          keys      = zip [1..] ann
          seqvarRule = case mseqvar of 
            Nothing   -> []
            Just sann -> [] --[rule] -- TODO similar to strict case but taking annotation into account

          mkRule k  = FStepRule step [Left premise] 
            where step = FStep pats (TApp (pack nm) terms) [] [] [] [] [] [] 
                  (pats,terms) = foldr op base keys
                    where base = case mseqvar of 
                                    Just _ -> ([PSeqVar "X*" StarOp]
                                              ,[TVar "X*"]) 
                                    _      -> ([], [])
                          op (k',sness) (pats, terms) 
                            | k' == k = (PMetaVar var:pats
                                        ,TVar (var ++ "'") : terms) 
                            | k' <  k, Strict <- sness = 
                                (PAnnotated (PMetaVar var) 
                                    (TSortSeq (TName "values") QuestionMarkOp):pats
                                ,TVar var : terms)
                            | True    = (PMetaVar var : pats, TVar var : terms)
                           where var = "X" ++ show k'
                  premise = FPremiseStep (TVar var) [PMetaVar (var ++ "'")] 
                              [] [] [] [] [] []
                    where var = "X" ++ show k 
