import re, sys, pathlib

def fix(text):
    out = []
    i = 0
    n = len(text)
    while i < n:
        m = re.compile(r'\bconst\b').search(text, i)
        if not m:
            out.append(text[i:])
            break
        start = m.start()
        out.append(text[i:start])
        j = m.end()
        while j < n and text[j] in ' \n\t':
            j += 1
        k = j
        while k < n and (text[k].isalnum() or text[k] in '_.<>'):
            k += 1
        while k < n and text[k] in ' \n\t':
            k += 1
        depth_char = text[k] if k < n and text[k] in '([{' else None
        contains_appcolors = False
        end = k
        if depth_char:
            pairs = {'(':')','[':']','{':'}'}
            close = pairs[depth_char]
            depth = 0
            p = k
            while p < n:
                c = text[p]
                if c in '([{':
                    depth += 1
                elif c in ')]}':
                    depth -= 1
                    if depth == 0:
                        end = p+1
                        break
                p += 1
            segment = text[j:end]
            if 'AppColors.' in segment:
                contains_appcolors = True
        if contains_appcolors:
            nxt = m.end()
            if nxt < n and text[nxt] == ' ':
                nxt += 1
            i = nxt
        else:
            out.append(text[start:m.end()])
            i = m.end()
    return ''.join(out)

for path in sys.argv[1:]:
    p = pathlib.Path(path)
    t = p.read_text(encoding='utf-8')
    nt = fix(t)
    if nt != t:
        p.write_text(nt, encoding='utf-8')
        print("fixed", path)
