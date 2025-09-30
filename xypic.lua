local system = require("pandoc.system")

local xy_doc_template = [[
\documentclass{standalone}
\usepackage{amsmath, amsthm}
\usepackage{fullpage}
\usepackage{comment}
\usepackage{graphicx}
\usepackage{xcolor}
\usepackage[all]{xy}
\usepackage{textcomp}

\usepackage{listings}
\lstset{
    language=C++,
    basicstyle=\ttfamily\small,
    upquote=true,
    extendedchars=false,
    aboveskip=18pt,
    belowskip=18pt,
    columns=fixed,
    showtabs=false,
    showspaces=false,
    showstringspaces=true,
    keepspaces=true,
    breaklines=false,
    morekeywords={cout,cin,endl,boolalpha,setprecision,size_t},
    morekeywords={[2]std,iostream,iomanip,ostream,cstdlib,cstddef,cassert,cmath,cstring,string,vector,utility,algorithm,initializer_list},
    sensitive=true,
    keywordstyle=\color{blue},
    keywordstyle={[2]\color{brown}},
    commentstyle=\color{gray}\scriptsize,
    stringstyle=\slshape,
    numbers=left,
    numberstyle=\color{cyan}\tiny,
    stepnumber=1,
    numbersep=28pt,
}
\lstdefinestyle{tiny}{
    basicstyle=\ttfamily\tiny,
    commentstyle=\color{gray}\tiny,
}
\lstdefinestyle{no-highlight}{
    keywordstyle=\color{black},
    keywordstyle={[2]\color{black}},
    stringstyle=\ttfamily,
    showstringspaces=false,
}
\lstloadlanguages{C++}

\usepackage[pdftex]{hyperref}
\hypersetup{colorlinks,linkcolor=blue,urlcolor=blue}


\begin{document}
\nopagecolor
%s
\end{document}
]]

local inlineMath_template = [[\\( %s \\)]]
local blockMath_template = [[\[
	%s
\] ]]

local function xy2image(src, filetype, outfile)
	-- os.execute("mkdir temp_xyimg")
	-- os.execute("cp 10Amacros.tex temp_xyimg/10Amacros.tex")
	-- os.execute("cd temp_xyimg")
	-- local f = io.open("xy.tex", "w")
	-- f:write(xy_doc_template:format(src))
	-- f:close()
	--
	-- os.execute("pdflatex xy.tex")
	-- if filetype == "pdf" then
	-- 	os.rename("xy.pdf", outfile)
	-- else
	-- 	os.execute("pdf2svg xy.pdf " .. outfile)
	-- end
	-- os.execute("mv " .. outfile .. "../" .. outfile)
	-- os.execute("cd ..")
	-- os.execute("rm xy.out && rm xy.log && rm xy.tex && rm xy.aux")
	system.with_temporary_directory("xy2img", function(tmpdir)
		system.with_working_directory(tmpdir, function()
			print(system.get_working_directory())
			-- print(system.list_directory(system.get_working_directory()))
			local f = io.open("xyimg.tex", "w")
			f:write(xy_doc_template:format(src))
			-- print(f:read())
			f:close()
			os.execute("ls")

			os.execute("pdflatex xyimg.tex")
			if filetype == "pdf" then
				os.rename("xyimg.pdf", outfile)
			else
				os.execute("pdf2svg xyimg.pdf " .. outfile)
			end
		end)
	end)
end

extension_for = {
	html = "svg",
	html4 = "svg",
	html5 = "svg",
	latex = "pdf",
	beamer = "pdf",
}

local function file_exists(name)
	local f = io.open(name, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

local function starts_with(start, str)
	return str:sub(1, #start) == start
end

function RawBlock(el)
	if starts_with("\\[xymatrixrowsep{48pt}", el.text) then
		print("Found diagram")
		local filetype = extension_for[FORMAT] or "svg"
		local fbasename = pandoc.sha1(el.text) .. "." .. filetype
		local fname = system.get_working_directory() .. "/" .. fbasename
		if not file_exists(fname) then
			xy2image(el.text, filetype, fname)
		end
		return pandoc.Para({ pandoc.Image({}, fbasename) })
	else
		return el
	end
end

function Math(el)
	print("Found math!")
	print(el.text:sub(2, 10))
	if el.text:sub(2, 9) == "xymatrix" then
		local filetype = extension_for[FORMAT] or "svg"
		local fbasename = pandoc.sha1(el.text) .. "." .. filetype
		local fname = system.get_working_directory() .. "/" .. fbasename
		if not file_exists(fname) then
			xy2image(el.text, filetype, fname)
		end
		print("Generated image...")
		el = pandoc.Image({}, fbasename)
		return el
	else
		if el.mathtype == "InlineMath" then
			print("Found inline math!")
			local str = el.text
			print(inlineMath_template:format(str))
			el = pandoc.Str(inlineMath_template:format(str))
			return el
		else
			return el
		end
	end
end

local fenced = "```\n%s\n```\n"
function CodeBlock(cb)
	-- print("Found code block!")
	-- -- use pandoc's default behavior if the block has classes or attribs
	-- print(cb)
	local new_attr = pandoc.Attr("", { "cpp" }, {})
	-- return pandoc.CodeBlock(cb.text, { class = "cpp" })
	cb = pandoc.CodeBlock(cb.text, new_attr)
	return cb
end
--
-- function InlineMath(el)
-- 	print("Found inline math!")
-- 	local str = el.text
-- 	el = pandoc.String(inlineMath_template:format(str))
-- 	return el
-- end
