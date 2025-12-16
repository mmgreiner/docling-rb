# ChatGPT

## Prompt

I'm ruby 3.4.7, i get this strange error message (in combination with PyCall): 

```
No such file or directory -- from multiprocessing.resource_tracker import main;main(11) (LoadError)
```

## Answer
This error is confusing because it *looks* like Ruby is trying to load a file called:

```
from multiprocessing.resource_tracker import main;main(11)
```

…but that string is actually **Python code**, not a filename.

### What’s really happening

When you use **PyCall**, Ruby embeds Python and sometimes launches **helper Python processes** (especially when Python uses `multiprocessing`, NumPy, joblib, etc.).

In newer Python versions, `multiprocessing` starts a helper process called **`resource_tracker`** like this (simplified):

```bash
python -c "from multiprocessing.resource_tracker import main; main(11)"
```

However, **Ruby 3.4 changed how `Kernel#load` and process spawning behave**, and PyCall ends up passing that Python `-c` command **incorrectly**, causing Ruby to treat the Python code string as a *filename to load*.

Hence Ruby raises:

```
LoadError: No such file or directory -- from multiprocessing.resource_tracker import main;main(11)
```

So:

* ❌ Ruby is not missing a file
* ❌ Python itself is not broken
* ✅ This is a **PyCall + Ruby 3.4 + Python multiprocessing incompatibility**

---

### Why it happens now

This typically occurs when **all three** are true:

1. Ruby **3.4.x** (newer process / load behavior)
2. PyCall (or PyCall-based gems)
3. Python ≥ 3.8 using `multiprocessing` (directly or indirectly)

Even if *you* didn’t import `multiprocessing`, libraries like:

* NumPy
* pandas
* joblib
* scikit-learn

can trigger it internally.

---

### Workarounds (pick one)

#### ✅ Option 1: Disable Python multiprocessing (most reliable)

Add this **before** PyCall initializes Python:

```ruby
ENV["PYTHONWARNINGS"] = "ignore"
ENV["OMP_NUM_THREADS"] = "1"
ENV["MKL_NUM_THREADS"] = "1"
```

And in Python-side code (via PyCall):

```python
import multiprocessing
multiprocessing.set_start_method("fork", force=True)
```

---

#### ✅ Option 2: Force Python to avoid `resource_tracker`

This is often enough:

```ruby
ENV["PYTHONMALLOC"] = "malloc"
```

Set it **before requiring `pycall`**.

---

#### ✅ Option 3: Use an older Python

If possible, Python **3.10 or 3.11** tends to be more stable with PyCall than 3.12+.

```bash
pyenv install 3.11.9
pyenv global 3.11.9
```

Then rebuild PyCall:

```bash
bundle pristine pycall
# or
gem uninstall pycall
gem install pycall
```

---

#### ⚠️ Option 4: Downgrade Ruby (temporary)

Ruby **3.3.x** does not trigger this issue:

```bash
rbenv install 3.3.6
rbenv local 3.3.6
```

---

### Long-term fix

This is a **known incompatibility**, not a user error. The real fix requires:

* PyCall updates to handle Ruby 3.4 process spawning correctly
* OR switching to **PythonCall.jl-style isolation** (not yet available in Ruby)

---

### Quick diagnosis question (optional)

If you want, tell me:

* Python version (`python --version`)
* PyCall version
* Whether this happens during import or when running code

I can give you a **minimal working configuration** for your setup.
