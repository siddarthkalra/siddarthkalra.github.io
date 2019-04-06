---
layout: post
title:  "Side Effects"
date:   2019-04-06 18:45:00
---

Side effects can have deadly consequences. We all pay attention to them when picking up a pack of antibiotics from the pharmacist. But are you paying attention to them when writing your next app feature? If you haven't been, I'm here to convince you that it's worth reading the fine-print and avoiding them whenever possible.

![Side Effects meme](/images/side-effects.jpg)

So, let's start by defining our terms. Side effects, in the realm of programming, are hidden consequences or changes. That is, when calling a function leads to something being accessed or changed outside the scope of that function. The function can then no longer be considered [pure](https://en.wikipedia.org/wiki/Pure_function). Here is an example of a pure function:

{% highlight swift %}
func multiplyBy2(_ value: Int) -> Int {
    return value * 2
}
{% endhighlight %}

We usually want to aim for pure functions whenever possible because they allow us to locally reason about our program as there is no global impact upon invocation. Introducing side effects means that we may no longer be able to reason locally as changes at the global scope can be introduced. This increases the complexity of our program.

Today we're going to discuss two types of side effects: **hidden inputs** and **hidden outputs**. As a general rule, hidden changes are something that you want to avoid. Having implicit changes can make your API unclear and unobvious, which can lead to misuse and unintended results. Now that we've covered what side effects are, let's examine each flavor in detail.

Say, I'm writing a chat messaging app to break the dominance of WhatsApp in the market. That's going to be tough, so let's ensure that our basics are right first. To do this, I need a way to represent messages in my program. We'll start by defining a data structure that describes the main building block of the app:

{% highlight swift %}
struct ChatMessage {
    let userName: String
    let message: String
    let creationDate: Date
}
{% endhighlight %}

Now, I might want to display the chat messages a given user has sent over the last day. For that, I could write a function like so:

{% highlight swift %}
func getLastDaysChatMessages() -> [ChatMessage]? {
  guard let rawChatMessages =
      UserDefaults.standard.array(forKey: "chatMessages") as? [RawChatMessage] else { return nil }

  let yesterday = Calendar.current.date(byAdding: .day,
                                        value: -1,
                                        to: Date())!

    return rawChatMessages
        .compactMap(transformDictToChatMessage)
        .filter { $0.creationDate > yesterday }
}
{% endhighlight %}

Even though this function gets the job done, we have a few problems. We've come across our first type of side effect. `UserDefaults.standard`, `Calendar.current` and `Date()` are all **hidden inputs**. `UserDefaults.standard` and `Calendar.current` are both singletons that can be altered by other parts of our program at any time. Also, since we only get the date at the time of invocation, this function will not produce predictable results if invoked multiple times, which reduces testability.

Let's see if we can restore predicability and remove outside influence to restore our ability to locally reason about this piece of code:

{% highlight swift %}
func getChatMessages(rawChatMessages: [RawChatMessage], filter: (ChatMessage) -> Bool) -> [ChatMessage] {
    return rawChatMessages
        .compactMap(transformDictToChatMessage)
        .filter(filter)
}

// Usage
let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!

getChatMessages(rawChatMessages: rawChatMessages,
                filter: { $0.creationDate > yesterday })
{% endhighlight %}

In our above solution, we've leveraged dependency injection to remove `UserDefaults.standard` and `Calendar.current` from the equation altogether. Our function no longer cares about these concepts, which makes tests much easier to write. We've also added the `filter` parameter. Now a date can be injected. This will allow us to get predictable results when the function is invoked multiple times as the date will not change during each invocation.

Now that we have a clean way to retrieve chat messages, what about saving new ones? Let's start by taking the following approach:

{% highlight swift %}
func saveChatMessages(_ chatMessages: [ChatMessage]) {
    chatMessages.forEach {
        AnalyticsManager.shared.recordChatMessage($0)
    }

    let rawChatMessages = chatMessages.map(transformChatMessageToDict)
    UserDefaults.standard.set(rawChatMessages, forKey: "chatMessages")
}
{% endhighlight %}

So, here we have an `AnalyticsManager` recording some information. Maybe we're interested in tracking which of our users are the most active or which topics users are discussing on a given day. We're also persisting our chat messages to user defaults.

There's a lot going on here. Both `AnalyticsManager` and `UserDefaults` are reaching out to the outside world and making some sort of change. They are both examples of **hidden outputs**. Testing this function is going to take a bit of work. We can do better by breaking things apart.

{% highlight swift %}
typealias ProcessMessage = (ChatMessage) -> Void

func saveChatMessages(_ chatMessages: [ChatMessage], processMessage: ProcessMessage?) -> [RawChatMessage] {
    if let processMessage = processMessage {
        chatMessages.forEach(processMessage)
    }

    return chatMessages.map(transformChatMessageToDict)
}
{% endhighlight %}

In this incarnation of our function, `AnalyticsManager` and `UserDefaults` are nowhere to be found so our tests don't have to worry about them. But we can still use both these classes in our app code. `AnalyticsManager` can be injected via the `processMessage` closure that can be optionally provided as a function parameter and we can process the raw chat messages and save them to `UserDefaults` by using the array returned by the function.

Side effects are quite common in many codebases. Our goal should always be to define a clear API and ensure that testing is not cumbersome. This is easier to do if we limit the side effects in our code. Introducing stronger forms of decoupling and ensuring that our functions are following the principal of [single responsibility](https://en.wikipedia.org/wiki/Single_responsibility_principle) can go a long way in limiting the amount of side effects we have to live with.

Have you come across other types of side effects in your code? If so, let me know on Twitter [@siddarthkalra](https://twitter.com/siddarthkalra). All other forms of feedback are welcome as well. Have a great day and props to you for reading till the end!
