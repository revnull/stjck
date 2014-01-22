
import Control.Monad
import Data.Char
import System.Environment

newtype Mu f = Mu (f (Mu f))

initial :: Mu []
initial = Mu []

fx :: Mu [] -> IO (Mu [])
fx (Mu l) = return x where x = (Mu (x:l))

push :: Mu [] -> IO (Mu [])
push (Mu l) = return $ Mu (initial:l)

pop :: Mu [] -> IO (Mu [])
pop (Mu (x:xs)) = return $ Mu xs

onHead :: (Mu [] -> IO (Mu [])) -> Mu [] -> IO (Mu [])
onHead fn (Mu (x:xs)) = do
    x' <- fn x
    return $ Mu (x':xs)

onTail :: (Mu [] -> IO (Mu [])) -> Mu [] -> IO (Mu [])
onTail fn (Mu (x:xs)) = do
    Mu xs' <- fn (Mu xs)
    return $ Mu (x:xs')

hd :: Mu [] -> IO (Mu [])
hd (Mu (x:_)) = return x

nul :: Mu [] -> IO (Mu [])
nul _ = return initial

nop :: Mu [] -> IO (Mu [])
nop = return

ifEmptyElse :: (Mu [] -> IO (Mu [])) -> (Mu [] -> IO (Mu [])) ->
    (Mu [] -> IO (Mu [])) -> Mu [] -> IO (Mu [])
ifEmptyElse look t f x = do
    Mu x' <- look x
    case x' of
        [] -> t x
        _ -> f x

printLength :: Mu [] -> IO (Mu [])
printLength x@(Mu l) = do
    putChar (chr $ length l)
    return x

printBinary :: Mu [] -> IO (Mu [])
printBinary x@(Mu l) = do
    putChar (chr $ addBits 0 l)
    return x
  where addBits b [] = b
        addBits b ((Mu []):rest) = addBits (b * 2) rest
        addBits b (_:rest) = addBits (1 + (b * 2)) rest
    
-- helper for the compiler
compose :: [Mu [] -> IO (Mu [])] -> Mu [] -> IO (Mu [])
compose = foldr (>=>) return

compile :: String -> Mu [] -> IO (Mu [])
compile l = prog where
    prog = compose $ fst $ compile' undef undef [] l
    undef = cycle [prog, return]
    compile' _ _ c [] = (reverse c, [])
    compile' b f c ('[':xs) = (l, xs'') where
        (l@(_:ls), xs'') = compile' b f (comp':c) xs'
        (comp, xs') = compile' (comp':b) (ls':f) [] xs
        comp' = compose comp
        ls' = compose ls
    compile' _ _ c (']':xs) = (reverse c, xs)
    compile' b f c ('\\':xs) = compile' b f ((b !! count):c) xs' where
        (count, xs') = gs 0 xs
        gs c ('\\':xs) = gs (c + 1) xs
        gs c xs = (c, xs)
    compile' b f c ('/':xs) = compile' b f ((f !! count):c) xs' where
        (count, xs') = gs 0 xs
        gs c ('/':xs) = gs (c + 1) xs
        gs c xs = (c, xs)
    compile' b f (ca:cb:cc:cs) ('?':xs) = compile' b f (exp:cs) xs where
        exp = ifEmptyElse ca cb cc
    compile' b f (c:cs) ('\'':xs) = compile' b f ((onHead c):cs) xs
    compile' b f (c:cs) ('\"':xs) = compile' b f ((onTail c):cs) xs
    compile' b f cs ('>':xs) = compile' b f (push:cs) xs
    compile' b f cs ('<':xs) = compile' b f (pop:cs) xs
    compile' b f cs ('=':xs) = compile' b f (fx:cs) xs
    compile' b f cs (';':xs) = compile' b f (hd:cs) xs
    compile' b f cs ('.':xs) = compile' b f (nul:cs) xs
    compile' b f cs ('|':xs) = compile' b f (nop:cs) xs
    compile' b f cs ('-':xs) = compile' b f (printLength:cs) xs
    compile' b f cs ('_':xs) = compile' b f (printBinary:cs) xs
    compile' b f cs (_:xs) = compile' b f cs xs

main = do
    args <- getArgs
    input <- case args of
        [] -> getContents
        (x:_) -> readFile x
    compile input initial

