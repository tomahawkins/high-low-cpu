# System TS/SCI Handling Requirements

# What's the System?

# A spectrum of solutions for handling multi security levels.

Address:

- Problem Framing
- Specification & Modeling
- Automation Potential

The choice of how to frame the problem,
ways to model and abstract the system to facilitate verification,
and possibilities for automation largely depend
the choice of implementation, which is 
is not just guided by security requirements,
but other functional requirements as well.  For example,
a signal intelligence mission that requires consuming large volumes
of signal data, possibly in realtime,
might rule out the option of manually transporting data in stored on physical media.

Or an intelligence officer who needs to produce both 
classified and unclassified information quickly may not have the
luxury to go back and forth between a secure and unsecure room;
they may need the ability to work from a single workstation,
quickly switch between security levels.

What follows is a brief survey (not definitive) of different implementation choices
to meet both security requirements and other requirements beside.
They range from simple to complex, not only in how they are implemented,
but also roughly terms of verification complexity.

1. Carting CDs (or old school tape and film) into a room.

Though this seems antiquated, if the application can tolerate the
bandwidth and latency limitations of transporting physical media, it's hard to
beat the security that this provides with minimal verification effort.
Assuming appropriate physical boundary security,
including personnel security protocols and power and RF isolation,
covert channels will be hard to develop.
Furthermore, equipment in the secure room needs little, if any, verification.

2. A Networking Data Check Valve (or diodes for the EEs)

If CDs are too slow, the next step could be a unidirectional network where
networking devices ensure data only flows one direction.
Simplify verification and reduce the chance of introduce possible side channels,
there should be no feedback mechanisms, e.g. no data acknowledgements, no resend requests.
To meet data transmission requirements, data rates would have to be set appropriately
in advance to minimize packet loss.  Forward error correction could also
be applied to recover from both bit errors and dropped packets.

3. Network File System (NFS)

Low side can read and write to NFS share, high side can only read.
If high side activity can block or otherwise affect the low side, this creates the possibility for side channels.

4. Secure VM Partitions / Secure OS Partitions

Though different these share similarities, namely a sandbox for a security domain
either in the form of a VM or a OS partition, where a supervisory system
(hypervisor or the OS), provides information flow control between the sandboxes.

5. Dynamic Information Flow Control (IFC)

Here data is labeled (tagged) with security information and
during processing labels are checked, merged, and propagated
with newly computed results.  Labels can either be managed
by software for could be enforced in the hardware.
Label granularity can vary: a label could be associated with a block of
data (coarse grained) for 


Data tagged or labeled with security infomation.  Processing steps
combine labels of input data to label results.
Different levels of granularity; coarse (labeling blocks of data) or fine (labeling individual machine words).

6. Compiler Enforced Static IFC

Same idea as 6, but done statically at compile time.



## Possible formal methods applied to different implementations.

### A blocking data check valve, file locking in a secure NFS

The pure form of a data check valve is not challenging from a verification standpoint -- ignoring
the more obscure power and RF side channels.
If however, we introduce the possibility of a throttling mechanism,
such as giving the high side the ability to temporarily block the channel or request a retransmission,
this opens the door to an indirect channel, which the low side may be able to use to gleam high side information.










 or a blocking 


// Compare corresponding registers between the two CPUs.  If either is labeled low, the values and the labels must be equal.
function automatic logic if_low_then_equal(value_label_t r1, value_label_t r2);
    return imply(!r1.label || !r2.label, r1 == r2);
endfunction










Dear Tom,
Thank you for taking the time to engage with us throughout the interview process. We were impressed
with our conversation and would like to invite you to complete a take-home exercise that reflects both
the strategic and executional aspects of the role.
The exercise is called a “Show and Tell”, consisting of two parts:

/ PART 1: THE “TELL”
Strategic Memo
A defense contractor is building a complex data processing and decision-support system as part of
the Department of Defense Combined Joint All Domain Command and Control (JADC2) initiative that
uses AI to enhance cross-domain capabilities.
One of the requirements this contractor must meet is:

“The system must comply with TS/SCI handling requirements, ensuring classified data is
properly isolated, labeled, and never spills into lower classification pipelines.”

The contractor is currently attempting to demonstrate compliance by logging system behavior and
showing there’s no evidence of data spillage, but this is challenging because they are trying to prove a
negative. They’ve turned to Argo in hopes of using formal methods to prove the affirmative: that their
system is designed and implemented in such a way that data flows and classification boundaries are
guaranteed to be enforced correctly. You’ve been asked to define a formal approach that could provide
this level of justifiable confidence.


Write a memo to Atalanta’s product and engineering teams that addresses the following:

1. Problem Framing
● How would you interpret the requirement formally?
● What assumptions or invariants must be made explicit before reasoning can begin?
● What are critical components or sub-properties we need to verify (e.g. data labeling
correctness, policy enforcement, channel isolation, etc.)?
● What critical assumptions or ambiguities need to be clarified before modeling or verifying it?

2. Specification & Modeling
● How would you represent this system formally?
● What abstractions would you use to model data flow, access control, classification levels, and
isolation properties?
● What logic or proof system (e.g. Lean, Coq, TLA+, etc) would be most appropriate, and why?
● What guarantees are out of scope? How would you communicate this to the customer?

3. Automation Potential
● What parts of the proof pipeline could be automated or assisted by LLMs?
● What should be human-guided vs. machine-generated in this context?
● How would you structure a workflow to make this proof creation accessible to a non-expert?

What We’re Evaluating:

● Logical Rigor – Can you design a formal approach that would stand up to real-world
certification needs?
● Communication – Did you clearly explain what you modeled, why, and what the proof shows?
● Tool Judgement – Do you know which framework is best suited for the task and why?
● Workflow Vision – Can you envision how formal methods integrate with AI tooling?


/ PART 2: THE “SHOW”
Demo the Proof
Submit a small, focused formal proof that illustrates your approach. You may use Lean, Coq, Isabelle,
TLA+, Alloy, or any proof or modeling language of your choice.
Some options include:
● A proof that models a simple data classification system and demonstrates non-interference
between classification levels.
● A model that encodes policies for TS/SCI data and proves that no unauthorized downgrade
path exists.
● A theorem proving that data labels are preserved through all processing stages.
● A representation of channel isolation that ensures no unintended information flow is possible.
You may keep this simple and illustrative; it doesn’t need to cover the full system. Focus on
demonstrating how one important aspect could be formally verified and what insight it provides.
What We’re Evaluating:
● Formal Methods Expertise – Can you construct meaningful, correct, and relevant formal
artifacts?
● Realism – Does your example plausibly connect to the actual requirement?
● Creativity – Did you find an elegant way to represent a complex problem?

/ SUBMISSION & NEXT STEPS
● Format: Please submit your memo as a PDF. Please submit your demo in a shareable format
(e.g. GitHub repo, Figma link, or deployed app.)
● Video Recording: Please also submit a video of a recorded walkthrough of your presentation.
This will allow us to spend our next conversation in conversation with you about your
submission, rather than watching the presentation for the first time.
v/r,
Anjana & Jonathan
