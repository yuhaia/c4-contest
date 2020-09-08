const fs = require('fs')
const path = require('path')
const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
const config = require('config-lite')(__dirname)
var jwt = require('jsonwebtoken')
const UserModel = require('../../models/users')
const ReportModel = require('../../models/report')
const QuestionnaireModel = require('../../models/questionnaire')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
var levels = {
  HIGH: 'A',
  MID: 'B',
  LOW: 'C'
}
const themes = {
  LIFE: "生活平衡测试",
  EMOTION: "情绪指数测试",
  POTENTIAL: "潜能测试"
}
// for in 无法保证输出顺序 所以姑且在数组里写死 方便feedback时使用
const life_child_groups = ["职业发展", "财务状况", "身心健康", "朋友家人", "亲密关系", "个人成长", "消遣娱乐", "自然环境"]
const emotion_evaluation_template = {
  "愤怒": {
    "A": "您经常会经历严重的愤怒情绪，甚至让您有失控感，您可以尝试一些情绪调节的方法有意识地控制自己的情绪强度。",
    "B": "您有时会体验到愤怒的情绪，如果愤怒的情绪给您带来困扰，您可以有意识地控制和调节。",
    "C": "您的愤怒情绪比较轻微，对生活影响较小，建议您继续保持良好的情绪状态。"
  },
  "困惑": {
    "A": "您的生活中体验到很多的困惑，建议您可以通过与身边的朋友交谈和阅读的方式解除疑惑，同时也请您注意用脑卫生，劳逸结合。",
    "B": "您时而有困惑的感觉，您可以通过和朋友交流和阅读来排解心中的疑惑，收获更加明朗的生活。",
    "C": "您的生活中较少体验到困惑的感觉，这说明您可以较好地应对大多数的生活问题。"
  },
  "抑郁": {
    "A": "您经常体验到消极、负面的心绪，或许这给您带来一种无力感，如果这种感觉过多以至于您无法应对，您可以考虑寻求心理咨询的帮助。",
    "B": "您有时会体验到抑郁相关的情绪，和一些无力感，拥有一两个爱好和一些可以尝尝沟通的好友将有助于您改善这类情绪。",
    "C": "您较少体验到抑郁的情绪，能够较好地应对生活的起伏，希望您继续保持良好的心态！"
  },
  "紧张不安": {
    "A": "您经常感到紧张不安，尽管适度的紧张感有助于提升效率，但过度紧张可能影响我们完成日常工作，您可以进行针对性的放松训练来降低紧张感，更从容地面对生活。",
    "B": "生活中，您时常会体验到紧张不安，适度的紧迫感有助于您完成日常任务，若您觉得这种紧张的感觉给自己带来了较大困扰，可以尝试着进行放松训练加以缓解。",
    "C": "您在生活中较少体验到紧张不安的感觉，多数时候您都能够从容地应对日常生活及挑战。"
  },
  "疲劳": {
    "A": "您经常感到十分疲劳、力不从心，建议您适度安排自己的日常任务，关注并提高自己的身体健康和睡眠质量，放松也是日常的重要部分，一张一弛才是生活之道。",
    "B": "您时常感到疲惫，建议您注意休息、劳逸结合，适度放松能让工作和学习事半功倍哦！",
    "C": "您很少体验到疲劳的感觉，说明您能够较好地安排日常的工作、学习和生活，请您继续保持！"
  },
  "活力": {
    "A": "您总是活力四射，有充足的精力完成日常工作，建议您继续保持健康的生活节奏。",
    "B": "多数时候您都是富有活力的，但有时可能会感到疲劳，建议您劳逸结合、合理安排作息。",
    "C": "您经常感觉到自己不是那么富有活力，如果您希望自己有更饱满的精力和充足的能量，不如从较为平缓的体育项目开始，先激活自己的身体吧！"
  }
}
const potential_evaluation_template = {
  "仁": {
    "general_evaluation": {
      "A": "“仁”是整个测评体系中的关爱部分。您在对自己、对他人和对环境时，都能做到真诚相待，真心爱护，这有助于您在得到内心和谐的同时，拥有较为和睦的人机关系，如果每个人都能达到您的水平，社会也能更加和谐。",
      "B": "“仁”是整个测评体系中的关爱部分。如果您能在对自己、对他人和对环境时，都能做到真诚相待，真心爱护，这有助于您在得到内心和谐的同时，拥有较为和睦的人机关系。",
      "C": "“仁”是整个测评体系中的关爱部分。如果您能在对自己、对他人和对环境时，都能做到真诚相待，真心爱护，这有助于您在得到内心和谐的同时，拥有较为和睦的人机关系。"
    },
    "child_groups": {
      "对自己": {
        "general_evaluation": {
          "A": "在对待自身方面，您的内心比较和谐，您身体健康、情绪稳定和幸福感这三项的综合水平处于较高的层次。身体健康是对自身关怀的基础，您在这个基础项目中做的不错；同时您能客观理性的看待事物，不易被一般情景引起强烈的情绪反应；而且您能积极面对生活，拥有较高的主观幸福感。",
          "B": "在对待自身方面，您处于中等水平，您身体健康、情绪稳定和幸福感这三项的综合水平也有进步孔家。身体健康是对自身关怀的基础，您在这个基础项目中做的不错；但如果您能更客观理性的看待事物，不易被一般情景引起强烈的情绪反应，更积极得面对生活，您就能与自己更好的相处。",
          "C": "在对待自身方面，您的内心还不太和谐，您身体健康、情绪稳定和幸福感这三项的综合水平还有待提高。身体健康是对自身关怀的基础，您需要更加注重锻炼和饮食；同时您还需联系如何客观理性的看待事物，不易被一般情景引起强烈的情绪反应；如果您能积极面对生活，您就拥有较高的主观幸福感。"
        },
        "child_groups": {
          "身体健康": {
            "A": "您的身体比较健康，还能保持有运动习惯：会积极参加有氧运动；同时您的生活习惯也非常好，睡眠充足，膳食均衡。 ",
            "B": "您的身体相对来说比较健康，建议您能培养良好的运动习惯，积极参加有氧运动；同时您的生活习惯也还不错，睡眠充足和膳食均衡能帮助您保持良好的体魄。",
            "C": "您的身体的健康程度还还有待提升，建议您能培养良好的运动习惯，积极参加有氧运动；同时您的生活习惯也还不错，睡眠充足和膳食均衡能帮助您保持良好的体魄。"
          },
          "情绪稳定": {
            "A": "您的情绪比较稳定，不易被一般情景引起强烈的情绪反应，或引起的情绪反应较为缓慢，情绪状态受外界（或内部）条件变化而产生波动较小。如当遇到事业成败等重大生活事件时，较易控制自己的情绪。",
            "B": "您有时会被一般情景引起强烈的情绪反应，情绪在一定程度上会受外界（或内部）条件变化而产生波动。如当遇到事业成败等重大生活事件时，还需要更好地控制自己的情绪。",
            "C": "您的情绪反应相对来说波动比较大，情绪比较容易受外界（或内部）条件变化而产生波动。如当遇到事业成败等重大生活事件时，还需要更好地控制自己的情绪，冷静下来才能更好地解决问题。"
          },
          "幸福感": {
            "A": "您能积极地面对世界，自我力量感也比较强，您还能做到主动争取个人生存和追求个人幸福的基本权利，科学地认识物质财富与幸福的关系，幸福在很大程度上取决于个人对于幸福的理解，而您对生活的理解方式能让您更容易感受到幸福。",
            "B": "您的主观幸福感在人群中处于中水平，如果您能更加积极地面对世界，增强自我力量感，主动争取个人生存和追求个人幸福的基本权利，科学地认识物质财富与幸福的关系，设置多样化多层次的生活目标，您会更容易产生幸福感，幸福在很大程度上取决于个人对于幸福的理解。",
            "C": "您的主观幸福感有较大的提升空间，建议您增强自我力量感，主动争取个人生存和追求个人幸福的基本权利；不要总是向上比较，适当向下比较，保持理性平和的心态；同时科学地认识物质财富与幸福的关系，设置多样化多层次的生活目标。"
          }
        }
      },
      "对他人": {
        "general_evaluation": {
          "A": "在对待他人方面，您能对他人的境遇感同身受，认真的倾听和理解他人；同时您也是一个自控力较强，对集体富有责任心，并且乐于奉献的人；另外您还非常善于与他人合作，能很好的处理团队关系。",
          "B": "在对待他人方面，您在一定程度上能对他人的境遇感同身受，认真的倾听和理解他人；但您的自控力和责任心还有提升空间，如果能更好的与他人合作，您就能更好的处理团队关系。",
          "C": "在对待他人方面，您较难对他人的境遇感同身受，您需要更加认真的倾听和理解他人；同时如果您能提升自己的自控力与合作能力，您也能较好的处理团队关系。"
        },
        "child_groups": {
          "同理心": {
            "A": "您的同理心比较强，能感同身受，体验他人的情绪，有悲悯之心、怜爱之心，设身处地地对他人的情绪和情感的认知性的觉知、把握与理解。您的情绪自控、换位思考、倾听能力以及表达尊重等与情商相关的方面都比较强。",
            "B": "您的同理心在人群中处于中等水平，您能在一定程度上能感同身受，体验他人的情绪，有悲悯之心、怜爱之心，设身处地地对他人的情绪和情感的认知性的觉知、把握与理解。您的情绪自控、换位思考、倾听能力以及表达尊重等与情商相关的方面还有值得提升的地方。",
            "C": "您的同理心还有待提高，在对他人的情绪感同身受，体验他人的情绪这一点上您做的还不够，您的情绪自控、换位思考、倾听能力以及表达尊重等与情商相关的方面还有值得提升的地方。"
          },
          "责任心": {
            "A": "您的责任性非常强，能认识到对自己和他人以及集体所负责任的认识，以及做到与之相应的遵守规范、承担责任和履行义务。对自身富有责任心的人一般有较强的自控力，而对集体富有责任心的人则会乐于奉献。",
            "B": "您的责任心在人群中处于中等水平，您在一定程度上能对自己和他人以及集体所负责任有所认识，能遵守与之相应的规范，具有承担责任和履行义务的自觉态度。但整体上还可以再加强一些。",
            "C": "您的责任心有待提升，您对自己和他人以及集体所负责任的认识、情感和信念还有些薄弱，以及与之相应的遵守规范、承担责任和履行义务的态度也可以更加自觉一些。这样还可以在一定程度上提升您的自控力。"
          },
          "合作心": {
            "A": "您的合作心比较强，您具有较强的大局意识、协作精神和服务精神等的综合。主要体现在个体愿意采取行动，甚至在一定程度上牺牲自我利益来保证组织的高效率运转，不过合作精神往往在个人利益与机体利益达成一致时更容易出现。合作精神较强的个体往往在处理团队人际关系以及团队矛盾时，都有巧妙的方法。",
            "B": "您的合作心比处于中等水平，您在一定程度上具有大局意识、协作精神和服务精神等的综合。但您如果能再个人和集体利益出现冲突时，更从大局角度来考虑，努力追求个人利益与机体利益达成一致，合作精神会更容易出现。合作精神较强的个体往往在处理团队人际关系以及团队矛盾时，都有巧妙的方法。",
            "C": "您的合作心还有待提高，尤其是在大局意识、协作精神和服务精神等的综合方面。但您如果能再个人和集体利益出现冲突时，更从大局角度来考虑，努力追求个人利益与机体利益达成一致，合作精神会更容易出现。合作精神较强的个体往往在处理团队人际关系以及团队矛盾时，都有巧妙的方法。"
          }
        }
      },
      "对环境": {
        "general_evaluation": {
          "A": "在对待环境方面，您具有较高的环保意识，能自觉做一些保护环境的小事；同时，您对于社会环境的理解也处于较高层次，个人的法制意识和国家意识也较强。",
          "B": "在对待环境方面，您具有比较高的环保意识，如果能自觉做一些保护环境的小事就更好了；同时，您对于社会环境的理解也也还能提高，个人的法制意识和国家意识的提升也能帮助您更好的理解这个世界。",
          "C": "在对待环境方面，您的环保意识还有待提升；同时，您对于社会环境的理解，个人的法制意识和国家意识稍显薄弱，如果能从大局来理解这个世界，您也能更好地与这个世界相处。"
        },
        "child_groups": {
          "环保意识": {
            "A": "您了解科学发展观，学习科学知识，将可持续发展植入自己的价值观中；同时您的卫生习惯也比较好，能做到保护环境从身边的小事做起。",
            "B": "您的环境意识处于中等水平，您在一定程度上了解科学发展观，也学习过科学知识，不过可持续发展还没有深入您自己的价值观中；同时您的卫生习惯还可以再提升一些，能做到保护环境从身边的小事做起。",
            "C": "您的环境意识还有待提高，这需要您更了解科学发展观，通过学习科学知识，将可持续发展的观念深入您自己的价值观中；同时您的卫生习惯还可以再提升一些，能做到保护环境从身边的小事做起。"
          },
          "法治意识": {
            "A": "您的法制意识比较强，您能通过学习法律知识，树立正确的法治观念；同时做到维护法律权威，自觉按法律办事，尊重法律地位；敢于和犯罪行为进行斗争，事前预防，事中和事后阻止，向司法或媒体举报犯罪行为。",
            "B": "您的法制意识处于中等水平，您曾学习法律知识，在一定程度上树立了正确的法治观念；同时做到维护法律权威，自觉按法律办事，尊重法律地位；但在面对犯罪行时，您还不能做到事前预防，事中和事后阻止，向司法或媒体举报犯罪行为。",
            "C": "您的法制意识还需提高，您能通过学习法律知识，树立正确的法治观念；维护法律权威，自觉按法律办事，尊重法律地位等方面来提高自己的法制意识。"
          },
          "国家意识": {
            "A": "您的国家意识比较强，您对国家的认同感很高，这是您基于对自己祖国的历史、文化、国情等的认识和理解，而逐渐积淀而成的一种国家主人翁责任感、自豪感和归属感。它是一种政治意识，同时也是一种文化意识，它能在很大程度上激发您的责任心和义务感。",
            "B": "您的国家意识处于中等水平，您对国家有认同感，这是您基于对自己祖国的历史、文化、国情等的认识和理解，而逐渐积淀而成的一种国家主人翁责任感、自豪感和归属感。它是一种政治意识，同时也是一种文化意识，它能在很大程度上激发您的责任心和义务感。",
            "C": "您的国家意识还有待提高，您对国家的认同感还比较薄弱，这需要您对自己祖国的历史、文化、国情等进行更加深入的认识和理解，而逐渐积淀而成的一种国家主人翁责任感、自豪感和归属感。它是一种政治意识，同时也是一种文化意识，它能在很大程度上激发您的责任心和义务感。"
          }
        }
      }
    }

  },
  "智": {
    "general_evaluation": {
      "A": "人类的智能是多元的，不仅仅是考试成绩能体现只能，它还展现在语言、音乐艺术、逻辑数理、视觉空间、身体运动、自我认识、人际沟通等方面，您的综合多元智能的水平较高。",
      "B": "人类的智能是多元的，不仅仅是考试成绩能体现只能，它还展现在语言、音乐艺术、逻辑数理、视觉空间、身体运动、自我认识、人际沟通等方面，您的综合多元智能的水平处于中等水平。",
      "C": "人类的智能是多元的，不仅仅是考试成绩能体现只能，它还展现在语言、音乐艺术、逻辑数理、视觉空间、身体运动、自我认识、人际沟通等方面，您的综合多元智能还有待提升。"
    },
    "child_groups": {
      "动手": {
        "general_evaluation": {
          "A": "在动手维度，您的动手制作以及观察探索能力均处于较高水平，能帮助您更好的完成与实际事物相接触的各项工作，请继续保持。",
          "B": "在动手维度，您的动手制作以及观察探索能力中有一些还需提升，这能帮助您更好的完成与实际事物相接触的各项工作。",
          "C": "在动手维度，您的动手制作以及观察探索能力均有待进步，这能帮助您更好的完成与实际事物相接触的各项工作，请继续保持。"
        },
        "child_groups": {
          "动手操作": {
            "A": "您的动手能力非常强，能把理论应用于实践中，使理论和实践相结合，同时还能能够灵活地、够创造性地利用所学理论为生产服务。",
            "B": "您的动手能力处于中等水平，您在一定程度上能把理论应用于实践中，使理论和实践相结合，但在灵活地、创造性地利用所学理论为生产服务这一点上还有待加强。",
            "C": "您的动手能力还有待提高，建议您多练习把理论应用于实践中，使理论和实践相结合，同时再试一试灵活地、创造性地利用所学理论为生产服务。"
          },
          "自然探索": {
            "A": "您探索自然的能力较强，您能认真思考把观察到的零散的、片面的，这就需要用思维联系起来；而且能做到观察时认真细致，做好观察记录，记录要忠于事实，不可加入主观意识。",
            "B": "您的探索自然的能力处于中等水平，认真思考，仅凭感官得到的材料是零散的、片面的，这就需要积极思维 , 把观察的现象用思维联系起来；同时观察要认真细致，每个细节、每个片段都是事物变化发展的重要组成部分，失之可能得出片面而错误的认识；做好观察记录，记录要忠于事实，不可加入主观意识。",
            "C": "您的探索自然的能力有待提高，您需要做到认真思考，仅凭感官得到的材料是零散的、片面的，这就需要积极思维 , 把观察的现象用思维联系起来；同时观察要认真细致，每个细节、每个片段都是事物变化发展的重要组成部分，失之可能得出片面而错误的认识；做好观察记录，记录要忠于事实，不可加入主观意识。"
          }
        }
      },
      "分析": {
        "general_evaluation": {
          "A": "在分析维度，您不仅知识水平和学习能力均处于较高水平，同时也具有良好的思维能力，能很好的分析现有信息，由表及里的得出深度结论。",
          "B": "在分析维度，您的知识水平和学习能力均处于中等水平，同时也具有较好的思维能力，不过在分析现有信息，由表及里的得出深度结论上，还有待提升。",
          "C": "在分析维度，您的知识水平和学习能力均有待提升，同时良好的思维能力能帮助您更好的分析现有信息，由表及里的得出深度结论，您在这方面也需要注意。"
        },
        "child_groups": {
          "学习理解": {
            "A": "您的学习理解能力较强，能时刻保持“空杯心态”，虚心向上；善于利用碎片时间来进行学习；多加阅读和思考；对学习结果进行回顾和总结。",
            "B": "您的学习理解能力处于中等水平，建议您时刻保持“空杯心态”，虚心向上；善于利用碎片时间来进行学习；多加阅读和思考；对学习结果进行回顾和总结。",
            "C": "您的学习理解能力还有待加强，建议您时刻保持“空杯心态”，虚心向上；善于利用碎片时间来进行学习；多加阅读和思考；对学习结果进行回顾和总结。"
          },
          "分析研究": {
            "A": "您的分析研究水平处于较高水平，您能在思维中把客观对象的整体分解为若干部分进行研究。您有能力可以把事物的每个要素、层次、规定性在思维中暂时分割开来进行考察和研究，搞清楚每个局部的性质、局部之间的相互关系以及局部与整体的联系。",
            "B": "您的分析研究水平处于中等水平，您能一定程度上在思维中把事物的整体分解为若干部分进行研究。您在把事物的每个要素、层次、规定性在思维中暂时分割开来进行考察和研究的能力有待加强，搞清楚每个局部的性质、局部之间的相互关系以及局部与整体的联系对您分析问题有所帮助。",
            "C": "您的分析研究水平有待提高，建议您在思维中把客观对象的整体分解为若干部分进行研究。您如果可以把事物的每个要素、层次、规定性在思维中暂时分割开来进行考察和研究，搞清楚每个局部的性质、局部之间的相互关系以及局部与整体的联系，有利于您提升自己的分析研究能力。"
          }
        }
      },
      "创造": {
        "general_evaluation": {
          "A": "创造需要个体具有较高的审美素养、开放的思维模式以及丰富的想象力，您在这几个方面的表现均比较不错，很适合参加创造性工作。",
          "B": "创造需要个体具有较高的审美素养、开放的思维模式以及丰富的想象力，您在这几个方面的表现均比较不错，但还有一定的提升空间，您可以尝试多参加一些创造性工作加以练习。",
          "C": "创造需要个体具有较高的审美素养、开放的思维模式以及丰富的想象力，您在这几个方面的表现均有待提高，在面对创造性工作时，您可能会觉有些难度。"
        },
        "child_groups": {
          "变革创新": {
            "A": "您具有较高的创新变革能力，您能超越界限，跳离现有框架，重新定义事物和事物之间的关系。这种能力需要个体找出事物间的相关性，或是相反特质，将既有的元素打破，拆解，增删后，重新组合，以呈现新的风貌、功能或是意图。",
            "B": "您的创新变革能力处于中等水平，您在一定程度上具有超越界限，跳离现有框架，重新定义事物和事物之间的关系。这种能力需要个体找出事物间的相关性，或是相反特质，将既有的元素打破，拆解，增删后，重新组合，以呈现新的风貌、功能或是意图，您可以在这些方面进行加强。",
            "C": "您的创新变革能力还有待提升，建议您在思考问题的时候能尝试着超越界限，跳离现有框架，重新定义事物和事物之间的关系。这种能力需要个体找出事物间的相关性，或是相反特质，将既有的元素打破，拆解，增删后，重新组合，以呈现新的风貌、功能或是意图。"
          },
          "艺术美感": {
            "A": "审美的范围极其广泛，包括建筑、音乐、舞蹈、服饰、陶艺、饮食、装饰、绘画等等。 审美存在于我们生活的各个角落。您的艺术审美能力较高，拥有健康的审美修养可以陶冶心情、愉悦精神，也可以调控情感。",
            "B": "审美的范围极其广泛，包括建筑、音乐、舞蹈、服饰、陶艺、饮食、装饰、绘画等等。 审美存在于我们生活的各个角落。您的艺术审美能力处于中等水平，拥有健康的审美修养可以陶冶心情、愉悦精神，也可以调控情感。",
            "C": "审美的范围极其广泛，包括建筑、音乐、舞蹈、服饰、陶艺、饮食、装饰、绘画等等。 审美存在于我们生活的各个角落。您的艺术审美还有待提升，拥有健康的审美修养可以陶冶心情、愉悦精神，也可以调控情感。"
          }
        }
      },
      "帮助": {
        "general_evaluation": {
          "A": "您是一个善解人意、周到、友好、大方、乐于助人的人，您的合作态度和对人性的乐观认识能够让你成为最好的合作者。",
          "B": "您在善解人意、周到、友好、大方、乐于助人的人表现不错，要是您对人性能够更加乐观一些，您有望成为最好的合作者。",
          "C": "您在善解人意和乐于助人的方面还有待提升，可能您的生活习惯让您减少了与他人的接触，但是如果您的合作态度和对人性的乐观认识能够提升一些，你也可以成为一个很好的合作者。"
        },
        "child_groups": {
          "帮助他人": {
            "A": "您是一个乐于助人的人，您能对他人能做到主动问候，学会倾听；真诚面对，缩短距离；关注他人，善解人意。",
            "B": "您在一定程度上是一个乐于助人的人，您如果能在对他人能做到主动问候，学会倾听；真诚面对，缩短距离；关注他人，善解人意就更好了。",
            "C": "您在乐于助人方面还有待提高，希望您能对他人能做到主动问候，学会倾听；真诚面对，缩短距离；关注他人，善解人意。"
          },
          "助力公益": {
            "A": "您非常热心公益，您能关心社会中的弱势群体，了解她们的困难和处境；还注意提升自己做公益的能力，包括能力和经济等层面；积极了解了解做公益的各种途径，为实践提供可能性。",
            "B": "您比较热心公益，您在一定程度上能关心社会中的弱势群体，了解她们的困难和处境；如果您能提升自己做公益的能力，包括能力和经济等层面，同时积极了解了解做公益的各种途径，对您的执行力会有很大的帮助。",
            "C": "您在热心公益的方面还有待提升，建议您多关心社会中的弱势群体，了解她们的困难和处境；如果您能提升自己做公益的能力，包括能力和经济等层面，同时积极了解了解做公益的各种途径，对您的执行力会有很大的帮助。"
          }
        }
      },
      "影响": {
        "general_evaluation": {
          "A": "您是一个影响力很强的人，比较适合作为一个组织者，领导管理一些队员，而且您的感染力和个人魅力也能为您的影响力提供很大的帮助，好好利用自己的这种特质吧！",
          "B": "您的影响力处于中等水平，您有一定的能力成为一个组织者，领导管理一些队员，但是您的感染力和个人魅力还需要提升，才能更好的完成这份工作！",
          "C": "您的影响力还有待提升，不太适合作为一个组织者、领导管理一些队员。如果有这种工作需要，建议您多尝试提升自己的表达和感染能力，同时在事务上提升自己的专业性，走权威路线，对您的帮助会更大！"
        },
        "child_groups": {
          "领导管理": {
            "A": "您的领导能力较强，您为了达成自身的目的，擅长采取一些劝说、说服的方式来影响他人的思想、情感或行为的倾向性，从而为自己的行为和观点寻求。您还能受到身边人群的自觉拥护，具有很强的领袖气质。",
            "B": "您的领导能力处于中等水平，您不太擅长为了达成自身的目的去劝说、说服他人，但您具有一定的领袖气质，能受到身边人群的自觉拥护。",
            "C": "您的领导能力还需要加强，您不太擅长为了达成自身的目的，采取一些劝说、说服的方式来影响他人的思想、情感或行为，另外您也缺乏一些领袖气质，这需要您提升自身的综合素质才能提升这项能力。"
          },
          "演讲表达": {
            "A": "您具有很强的演讲表达能力，而且注重知识的积累和表达的多样化；您能在人际交往中注意自己的形象，提升自己的人格魅力；而且还能创造与被影响个体之间的融洽度和信任感。",
            "B": "您的演讲表达能力处于中等水平，如果想提高自己这方面的能力，建议您更加注重知识的积累和表达的多样化；同时需要您能在人际交往中注意自己的形象，提升自己的人格魅力；而且多利用群体和环境的力量。",
            "C": "您的演讲表达能力还有待提升，如果想提高自己这方面的能力，建议您需要注重知识的积累和表达的多样化；同时需要您能在人际交往中注意自己的形象，提升自己的人格魅力；而且多利用群体和环境的力量。"
          }
        }
      },
      "组织": {
        "general_evaluation": {
          "A": "您是一个善于计划和安排的人，在处理较大的目标和任务时，您的思路比较清晰，而且认真细致的个人品质也能帮您更好的组织安排各项任务。",
          "B": "您是一个善于计划和安排的人，但是在处理较大的目标和任务时，您还觉得有一些难度，认真细致的个人品质也能帮您很好的组织安排各项任务，但同时如果您思考问题时更考虑全局因素，您的计划会更顺利。",
          "C": "您觉得计划、安排和处理较大的目标和任务有一些难度，有些难理清思路，您可以从认真细致这一点开始着手，这能帮您更好的组织安排各项任务。"
        },
        "child_groups": {
          "计划安排": {
            "A": "您计划安排的能力比较强，能为了完成某个目标而合理安排自己行动的能力。其具体过程可分为构思目标、分析现况、归纳方向、评估可行性，一直到拟订策略、实施方案、追踪成效",
            "B": "您计划安排的能力处于中等水平，建议您从计划的流程上更加完善自己的计划过程，其具体过程可分为构思目标、分析现况、归纳方向、评估可行性，一直到拟订策略、实施方案、追踪成效与评估成果等。",
            "C": "您计划安排的能力还有待提高，建议您从计划的流程上更加完善自己的计划过程，其具体过程可分为构思目标、分析现况、归纳方向、评估可行性，一直到拟订策略、实施方案、追踪成效与评估成果等。"
          },
          "细致高效": {
            "A": "您是一个富有耐心、并且具有认真仔细的品质的人，具有细致高效的特点。从而您在完成任务方面，也能做到高效完成，尤其是在文字处理和数据处理等模式统一又需要耐心的方面体现的尤为明显。",
            "B": "您在一定程度上是一个富有耐心、并且具有认真仔细的品质的人，但有时因为过于细致可能会影响您的做事效率，建议您在完成任务方面，尤其是在文字处理和数据处理等模式统一又需要耐心的方面可以增强一些自己的效率。",
            "C": "您不算一个富有耐心的人，在细致方面也需要改进和提高，尤其是在文字处理和数据处理等模式统一又需要耐心的方面，您的这点劣势体现的比较明显，建议您做事时需要投入更多的耐心和细心。"
          }
        }
      }
    }

  },
  "勇": {
    "general_evaluation": {
      "A": "对过去、现在、未来有积极的态度，有良好的行动力，才能让一个人展现出对生活的热爱和活力，才能更好的理解并适应这个世界，很幸运，您在这一点做的非常不错！",
      "B": "对过去、现在、未来有积极的态度，有良好的行动力，才能让一个人展现出对生活的热爱和活力，才能更好的理解并适应这个世界，很幸运，您在这一点做的尚可！",
      "C": "对过去、现在、未来有积极的态度，有良好的行动力，才能让一个人展现出对生活的热爱和活力，才能更好的理解并适应这个世界，很幸运，您在这一点上还有待提升！"
    },
    "child_groups": {
      "对未来": {
        "general_evaluation": {
          "A": "在对待那些还没有发生的事时，您特别显著的展示了自己积极乐观的特质，您具有很强的能力感，相信自己足够应对很多未知的事，同时您在面对问题和挑战的时候，能更多的关注如何解决，而不是纠结发生的原因，这对于您积极处理将来的未来，有非常大的帮助。",
          "B": "在对待那些还没有发生的事时，您能积极乐观的去面对，您在自己擅长的领域有很强的能力感，但在面对未知时，还有待提升；您在面对问题和挑战的时候，能更多的关注如何解决，而不是纠结发生的原因，这对于您积极处理将来的未来，有非常大的帮助。",
          "C": "在对待那些还没有发生的事时，您特别需要积极乐观的特质，您具有一些的能力感，但有时不太相信自己足够应对很多未知的事，如果您在面对问题和挑战的时候，能更多的关注如何解决，而不是纠结发生的原因，对于您积极处理将来的未来，会有非常大的帮助。"
        },
        "child_groups": {
          "自我效能": {
            "A": "您的自我效能较高，您认为自己在特定情景中从事某种行为，并能较容易地取得预期结果的信念。自我效能是指人们对自己实现特定领域行为目标所需能力的信心或信念，简单来说就是个体对自己能够取得成功的信念。您的这种信念就比较强，这有助于提升您的做事动力。",
            "B": "您的自我效能处于中等水平，自我效能指您自己对自我能力的感觉；也是指人们对自己实现特定领域行为目标所需能力的信心或信念，简单来说就是个体对自己能够取得成功的信念，您在某些自己擅长的领域对自己的能力较为信任，但在陌生领域仍有所怀疑。",
            "C": "您的自我效能还需提高，您对自己在特定情境中并能较容易地取得预期结果的信念并不坚定。您的这种信念稍微有些薄弱，如果能针对性的提升，助于提升您的做事动力。"
          },
          "乐观": {
            "A": "您是一个自信乐观，耐受挫折的人，容易对周围人与事物产生正面的认知取向。您的认知准确，内驱力旺盛，有意识的动机明显，有稳定的情绪、情感和坚定的意志，能理性辨别诱因，积极地看待挫折，辩证地对待得失。",
            "B": "您在大多数情况下一个自信乐观的人您，容易对周围人与事物产生正面的认知取向。但是在一些您比较在意的事上如果收到了挫折，对您的影响会比较大，建议您理性辨别诱因，积极地看待挫折，辩证地对待得失。",
            "C": "您在自信乐观，耐受挫折这一点上还有待提高，您不太容易对周围人与事物产生正面的认知取向。您对有的事物的认知更容易从负面去考虑，发掘事物的缺漏是人类进化演变出来的本能，但理性辨别诱因，积极地看待挫折，辩证地对待得失，能提升您做事的积极性和动力。"
          },
          "聚焦解决": {
            "A": "您是一个聚焦解决的人，您对待问题的方式更倾向于是如果解决它，而不是发现问题原因；您能以正向的、朝向未来的、朝向目标的积极态度促使改变的发生。",
            "B": "您在很多情况下是一个聚焦解决的人，在很多情况下您对待问题的方式更倾向于是如果解决它，而不是发现问题原因；一般您能以正向的、朝向未来的、朝向目标的积极态度促使改变的发生，如果您能在一些特殊情况下人就坚持就更好了。",
            "C": "您在对待问题的方式上还有待改进，您对待问题的方式并不是如果解决它，而是探究问题发生的原因，但其实有些问题的原因已经发生，没办法改变了，只有聚焦解决才能更好的面向未来；如果您能具有以正向的、朝向未来的、朝向目标的积极态度，就更容易促使改变的发生。"
          }
        }
      },
      "对过程": {
        "general_evaluation": {
          "A": "在做一件事的时候，您总能投入其中，全心全力积极面对，俗话说行动改变世界，像您这样具有行动力，还能客观分析任务，分清轻重缓急的人，处理事务能相对游刃有余一些。",
          "B": "在做一件事的时候，您有时能投入其中，全心全力积极面对，俗话说行动改变世界，如果您能更具有行动力，还能客观分析任务，分清轻重缓急，处理事务能更游刃有余一些。",
          "C": "在做一件事的时候，您需要投入其中，全心全力积极面对，这样才能拥有行动力；同时客观分析任务，分清轻重缓急您也需要提升，这样您在处理事务能相对游刃有余一些。"
        },
        "child_groups": {
          "沉浸投入": {
            "A": "沉浸投入就是享受做的事情，沉浸在做的事情中，并能够产生心流体验。心流在心理学中是一种某者在专注进行某行为时所表现的心理状态，心流产生时同时会有高度的兴奋及充实感。您在这一方面做的比较好。 ",
            "B": "沉浸投入就是享受做的事情，沉浸在做的事情中，并能够产生心流体验。心流在心理学中是一种某者在专注进行某行为时所表现的心理状态，心流产生时同时会有高度的兴奋及充实感。您在这一方面做的处于人群中的中等水平。",
            "C": "沉浸投入就是享受做的事情，沉浸在做的事情中，并能够产生心流体验。心流在心理学中是一种某者在专注进行某行为时所表现的心理状态，心流产生时同时会有高度的兴奋及充实感。您在这一方面还有待加强。"
          },
          "行动积极": {
            "A": "您是一个行动积极的人，具有较强的执行力，您很少被拖延所困扰，拖延也可以看成对重要的事情不能持续的坚持和投入，而行动积极则是做事情能聚焦在重要的事情上，并坚持完成。",
            "B": "您在大多数情况下是一个行动积极的人，具有较强的执行力，但在遇到了一些困难的事情时，您也会被拖延所困扰，行动积极则是做事情能聚焦在重要的事情上，并坚持完成，如果您能在难度较大的情况下仍然坚持做事，对您会有较大的帮助。",
            "C": "您在行动积极方面还有待提高，如果您能有更强的执行力，您就不会再被拖延所困扰，拖延也可以看成对重要的事情不能持续的坚持和投入，而行动积极则是做事情能聚焦在重要的事情上，并坚持完成。"
          },
          "生活平衡": {
            "A": "您能较好的平衡生活、工作、学习、娱乐等关系，以平衡促发展。您能通过事先规划和运用一定的技巧、方法与工具实现对时间的灵活以及有效运用。",
            "B": "您再大多数情况下能平衡工作、学习、娱乐等关系，以平衡促发展，但要做的更好，需要您对工作、学习和娱乐的时间进行合理分配，通过事先规划和运用一定的技巧、方法与工具实现对时间的灵活以及有效运用。",
            "C": "对您来说，如何平衡工作、学习、娱乐等关系是一个难题。要做到平衡这些因素，则需要对工作、学习和娱乐的时间进行合理分配，通过事先规划和运用一定的技巧、方法与工具实现对时间的灵活以及有效运用。您可以着手从这一点上进行加强。"
          }
        }
      },
      "对结果": {
        "general_evaluation": {
          "A": "在面对现有的结果时，您不会过分抱怨，而是能以一种接纳的态度，反思提升，往事已矣，处理好负面情绪，压力也能转化成动力。",
          "B": "在面对现有的结果时，您偶尔会抱怨，如果能以一种接纳的态度您会有更大的进步，反思提升，往事已矣，处理好负面情绪，压力也能转化成动力。",
          "C": "在面对现有的结果时，您有时会过分抱怨，如果您能改掉这一点，以一种接纳的态度，反思提升，往事已矣，处理好负面情绪，压力也能转化成动力。"
        },
        "child_groups": {
          "接纳": {
            "A": "接纳就是对过去已经发生的事情，做的决定不痛苦、不后悔。您在这一点上做的很好，这种对待问题的方式能帮助你更好的成长。",
            "B": "接纳就是对过去已经发生的事情，做的决定不痛苦、不后悔。您在这一点上处于人群中的中等水平。如果一味的沉浸于消极的情绪中，就不能正视事情本身带给自己的影响，也更提不上会收获成长了。",
            "C": "接纳就是对过去已经发生的事情，做的决定不痛苦、不后悔。您在这一点还有待提高。如果一味的沉浸于消极的情绪中，就不能正视事情本身带给自己的影响，也更提不上会收获成长了。"
          },
          "韧性": {
            "A": "您是一个具有韧性的人，它使你能在压力下复原和成长，在面对丧失、困难或者逆境时，您能够有效应对和适应。这意味着您能在重大创伤或应激之后恢复最初状态，在压力的威胁下能够顽强持久、坚韧不拔，在挫折后的成长和新生。",
            "B": "您的韧性处于中等水平，它使你在一定程度上能在压力下复原和成长，在面对丧失、困难或者逆境时，您一般能够有效应对和适应。但您仍旧需要提升在重大创伤或应激时，自己的抗挫折能力。",
            "C": "您在抗打击和韧性这点上，还有较大的提升空间，它使你能在压力下复原和成长，在面对丧失、困难或者逆境时，您能够有效应对和适应。如果您能拥有较强的心理仍新，您就在重大创伤或应激之后恢复最初状态，在压力的威胁下能够顽强持久、坚韧不拔。"
          },
          "反思": {
            "A": "您是一个善于反思的人，能够从过去发生的事情中吸取成功的经验和失败的教训。它可以帮助我们从实践B析自己的行为和策略，进而进行调整和提升。",
            "B": "您在反思这一点的能力上处于中等水平，能够从过去发生的事情中吸取成功的经验和失败的教训，但遇到一些复杂情景时，可能反思能力不够您进行应对，如果您能针对性的加强这一点，从实践B析自己的行为和策略，您会更容易进行调整和提升。",
            "C": "您不太善于反思，在这一点上您还有待加强，如果您能从过去发生的事情中吸取成功的经验和失败的教训，那么可以帮助您自己从实践B析自己的行为和策略，进而进行调整和提升。"
          }
        }
      }
    }
  }
}

function getAverageScoreAndLevel(scores, maxest_value) {
  var total_scores = 0
  var level = ""
  var average_score = 0
  var left = 0
  var right = 0
  for (var i = 0; i < scores.length; ++i) {
    total_scores += scores[i] * 1
  }
  average_score = total_scores / scores.length
  if (maxest_value == 10) {
    left = 4
    right = 7
  } else if (maxest_value == 5) {
    left = 2
    right = 4
  }
  if (average_score < left) {
    level = levels.LOW
  } else if (left <= average_score && average_score <= right) {
    level = levels.MID
  } else if (right < average_score) {
    level = levels.HIGH
  }
  var info = {
    "average_score": average_score,
    "total_score": maxest_value,
    "level": level
  }
  return info
}

function getLifeSuggestion(theme, scores) {
  if (theme == themes.LIFE) {
    // console.log(scores)
    // low_satisfied_keys eg: "职业发展, 财务状况"

    if (scores.length > 8) {
      scores.length == 8
    } else if (scores.length < 8) {
      for (var i = scores.length; i < 8; ++i) {
        scores.push(0)
      }
    }

    var low_satisfied_keys = ""
    var mid_satisfied_keys = ""
    var high_satisfied_keys = ""

    var low_sentence = ""
    var mid_sentence = ""
    var high_sentence = ""
    for (var i = 0; i < scores.length; ++i) {
      if (scores[i] <= 3) {
        low_satisfied_keys += (" [" + life_child_groups[i] + "]")
      } else if (3 <= scores[i] && scores[i] <= 7) {
        mid_satisfied_keys += (" [" + life_child_groups[i] + "]")
      } else {
        high_satisfied_keys += (" [" + life_child_groups[i] + "]")
      }
    }
    if (low_satisfied_keys == "") {
      low_sentence = "\n您没有满意度较低的部分\n"
    } else {
      low_sentence = "\n您对于" + low_satisfied_keys + "的满意度较低，这些部分是您当前生活亟待提升之处，您可以有计划地分配一些时间到这些方面上，这些方面的提高能够有效改善您的生活平衡度;\n"
    }

    if (mid_satisfied_keys == "") {
      mid_sentence = "\n您没有满意度居中的部分\n"
    } else {
      mid_sentence = "\n您对于" + mid_satisfied_keys + "的满意度居中，若您有多余的精力，可以留意加强这些方面;\n"
    }

    if (high_satisfied_keys == "") {
      high_sentence = "\n您没有满意度较高的部分\n"
    } else {
      high_sentence = "\n您对于" + high_satisfied_keys + "的满意度较高，建议您继续保持对这些部分的关注，它们是您当前生活中的重要积极资源\n"
    }

    var life_evaluation_suggestion = "在上述八个生活的组成部分中，" + low_sentence + mid_sentence + high_sentence + "\n关于上述测评中，您感到不甚满意的方面，可以在“资源”中选择相关的课程或资料进行提升哦~ 相信您一定可以让自己的生活满意度Up Up Up!"
    return life_evaluation_suggestion
  }
}
// 生活平衡测试或情绪指数测试的getReport
function getLifeOrEmotionReport(questionnaire, report, scores) {
  // // console.log(questionnaire.groups)
  // // console.log("\n\n\n\n\n")
  // // console.log(report)
  // 可以改变report的值
  // report.groups = questionnaire.groups

  // // console.log("scores:")
  // // console.log(scores)
  // for(var i = 0; i < scores.length; ++i) {
  //   // console.log(scores[i] + "\n")
  // }


  report.result = {}
  var maxest_value = questionnaire.maxest_value
  // 总体评估
  var general_evaluation = {}
  general_evaluation.des = questionnaire.theme

  var general_info = getAverageScoreAndLevel(scores, maxest_value)

  general_evaluation.scores = scores
  
  general_evaluation.average_score = general_info.average_score
  general_evaluation.total_score = general_info.total_score
  general_evaluation.level = general_info.level
  if (general_evaluation.level == levels.HIGH) {
    general_evaluation.eval_des = "您的 " + questionnaire.theme + " 总体评估情况是" + general_evaluation.level
  } else if (general_evaluation.level == levels.MID) {
    general_evaluation.eval_des = "您的 " + questionnaire.theme + " 总体评估情况是" + general_evaluation.level
  } else if (general_evaluation.level == levels.LOW) {
    general_evaluation.eval_des = "您的 " + questionnaire.theme + " 总体评估情况是" + general_evaluation.level
  }

  if (questionnaire.theme == "生活平衡测试"){
    general_evaluation.suggestion = getLifeSuggestion("生活平衡测试", scores)
  } else {
    general_evaluation.suggestion = "请往下翻阅各个维度的测评建议"
  }
  report.result.general_evaluation = general_evaluation

  // 各维度的评估
  report.result["child_groups"] = {}
  for (var key in questionnaire.groups) {
    var detail = questionnaire.groups[key]
    var items = detail.items

    // console.log(items)
    var this_group_scores = []
    for (var i = 0; i < items.length; ++i) {
      // 问卷问题列表的索引是从1开始的
      var index = items[i] - 1
      var score = scores[index]
      // console.log("score:" + score)
      this_group_scores.push(score)
    }
    // console.log(this_group_scores)
    var info = getAverageScoreAndLevel(this_group_scores, maxest_value)
    detail.scores = this_group_scores
    detail.average_score = info.average_score
    detail.total_score = info.total_score
    detail.level = info.level
    // console.log(detail)
    var eval_des = ""
    if (detail.level == levels.HIGH) {
      eval_des = "您的" + key + "指数是" + detail.level
    } else if (detail.level == levels.MID) {
      eval_des = "您的" + key + "指数是" + detail.level
    } else if (detail.level == levels.LOW) {
      eval_des = "您的" + key + "指数是" + detail.level
    }
    detail.eval_des = eval_des
    if (questionnaire.theme == themes.EMOTION) {
      detail.suggestion = emotion_evaluation_template[key][detail.level]
    } else if (questionnaire.theme == themes.LIFE) {
      // detail.suggestion = getLifeSuggestion(questionnaire.theme, report.scores)
      detail.suggestion = ""
    }
    // // console.log(key)
    // // console.log(detail)
    report.result["child_groups"][key] = detail
  }

}

function getPotentialSuggestion(theme, which_level, key1, key2, key3, level) {
  if (theme == themes.POTENTIAL) {
    if (which_level == 3) {
      return potential_evaluation_template[key1]["child_groups"][key2]["child_groups"][key3][level]
    } else if (which_level == 2) {
      return potential_evaluation_template[key1]["child_groups"][key2]["general_evaluation"][level]
    } else if (which_level == 1) {
      return potential_evaluation_template[key1]["general_evaluation"][level]
    }
  }
}
// 潜能测试的getReport
function getPotentialReport(questionnaire, report, scores) {
  var debug = 1
  // // console.log(questionnaire.groups)
  // // console.log("\n\n\n\n\n")
  // // console.log(report)
  // 可以改变report的值
  // report.groups = questionnaire.groups
  report.result = {}

  report.result = {}
  var maxest_value = questionnaire.maxest_value
  
  // 总体评估
  var general_evaluation = {}
  general_evaluation.des = questionnaire.theme

  var general_info = getAverageScoreAndLevel(scores, maxest_value)

  general_evaluation.scores = scores
  general_evaluation.average_score = general_info.average_score
  general_evaluation.total_score = general_info.total_score
  general_evaluation.level = general_info.level
  if (general_evaluation.level == levels.HIGH) {
    general_evaluation.eval_des = "您的 " + questionnaire.theme + " 总体评估情况是" + general_evaluation.level
  } else if (general_evaluation.level == levels.MID) {
    general_evaluation.eval_des = "您的 " + questionnaire.theme + " 总体评估情况是" + general_evaluation.level
  } else if (general_evaluation.level == levels.LOW) {
    general_evaluation.eval_des = "您的 " + questionnaire.theme + " 总体评估情况是" + general_evaluation.level
  }

  general_evaluation.suggestion = "请往下翻阅各个维度的测评建议"
  report.result.general_evaluation = general_evaluation

  // 各维度的评估
  report.result["child_groups"] = {}
  var theme = questionnaire.theme
  var anti_questions = questionnaire.anti_questions
  for (var key1 in questionnaire.groups) {
    // key1 = 仁 智 勇
    var first_level_detail = {}
    first_level_detail.des = questionnaire.groups[key1].des

    report.result["child_groups"][key1] = {}
    var second_level_groups = questionnaire.groups[key1].child_groups
    var first_level_groups_scores = []
    report.result["child_groups"][key1]["child_groups"] = {}
    for (var key2 in second_level_groups) {
      // key2 = 对自己、对他人 etc
      var second_level_detail = {}
      second_level_detail.des = second_level_groups[key2].des

      report.result["child_groups"][key1]["child_groups"][key2] = {}
      var third_level_groups = second_level_groups[key2].child_groups
      var second_level_groups_scores = []
      report.result["child_groups"][key1]["child_groups"][key2]["child_groups"] = {}
      for (var key3 in third_level_groups) {
        // key3 = 身体健康、情绪稳定 etc
        report.result["child_groups"][key1]["child_groups"][key2]["child_groups"][key3] = {}
        var third_level_detail = {}
        third_level_detail.des = third_level_groups[key3].des

        var items = third_level_groups[key3].items
        var third_level_groups_scores = []
        for (var i = 0; i < items.length; ++i) {
          // 问卷问题列表的索引是从1开始的 注意区分反题的存在
          if (items[i] in anti_questions) {
            var score = 6 - scores[items[i] - 1]
            third_level_groups_scores.push(score)
          } else {
            var score = scores[items[i] - 1]
            third_level_groups_scores.push(score)
          }
        }
        // 累积到key2的scores中
        second_level_groups_scores = second_level_groups_scores.concat(third_level_groups_scores)

        // console.log("third_level_groups_scores", third_level_groups_scores)
        var info = getAverageScoreAndLevel(third_level_groups_scores, maxest_value)
        third_level_detail.scores = third_level_groups_scores
        third_level_detail.average_score = info.average_score
        third_level_detail.total_score = info.total_score

        third_level_detail.level = info.level
        third_level_detail.eval_des = "您的" + key3 + "指数是" + third_level_detail.level

        var which_level = 3
        third_level_detail.suggestion = getPotentialSuggestion(theme, which_level, key1, key2, key3, third_level_detail.level)

        report.result["child_groups"][key1]["child_groups"][key2]["child_groups"][key3] = third_level_detail


        if (debug == 1) {
          // console.log("\n\n\n\n")
          // // console.log(report.result["child_groups"])
          // // console.log(report.result["child_groups"][key1])
          // // console.log(report.result["child_groups"][key1][key2])
          // // console.log(report.result["child_groups"][key1][key2][key3])
          debug = 0
        }
      }

      first_level_groups_scores = first_level_groups_scores.concat(second_level_groups_scores)
      var info = getAverageScoreAndLevel(second_level_groups_scores, maxest_value)
      second_level_detail.scores = second_level_groups_scores
      second_level_detail.average_score = info.average_score
      second_level_detail.total_score = info.total_score

      second_level_detail.level = info.level
      second_level_detail.eval_des = "您的" + key2 + "指数是" + second_level_detail.level

      var which_level = 2
      second_level_detail.suggestion = getPotentialSuggestion(theme, which_level, key1, key2, "", second_level_detail.level)

      report.result["child_groups"][key1]["child_groups"][key2].general_evaluation = second_level_detail
    }

    var info = getAverageScoreAndLevel(second_level_groups_scores, maxest_value)
    first_level_detail.scores = first_level_groups_scores
    first_level_detail.average_score = info.average_score
    first_level_detail.total_score = info.total_score

    first_level_detail.level = info.level
    first_level_detail.eval_des = "您的" + key1 + "指数是" + first_level_detail.level

    var which_level = 1
    first_level_detail.suggestion = getPotentialSuggestion(theme, which_level, key1, "", "", first_level_detail.level)

    report.result["child_groups"][key1].general_evaluation = first_level_detail
  }
}

var verifyToken = require('../auth/verifyToken');
// TODO 需要支持动态扩展功能，而不是写死规则
router.post('/', verifyToken, function (req, res, next) {
  console.log("request to ../reports/submit:")

  var user_id = req.user_id
  const questionnaire_id = req.fields.questionnaire_id
  const scores = req.fields.scores
  const time = Date.now()
  var report = {
    user_id: user_id,
    time: time
  }

  QuestionnaireModel.getQuestionnaireByID(questionnaire_id)
    .then(function (questionnaire) {
      // console.log(questionnaire)
      var questionnaire_info = {}
      questionnaire_info = questionnaire
      if (!questionnaire) {
        // console.log('obtain questionnaire failed，questionnaire not found')
        res.status(404)
        res.json({ 'error': '问卷不存在' })
      } else {
        // console.log("obtain questionnaire successfully")
        // console.log(questionnaire)
        const questionnaire_theme = questionnaire.theme
        // 下面这段代码只是单纯的针对这三个问卷
        if (questionnaire_theme == themes.LIFE) {
          // console.log("questionnaire_theme == 生活平衡测试")
          getLifeOrEmotionReport(questionnaire, report, scores)
        } else if (questionnaire_theme == themes.EMOTION) {
          // console.log("questionnaire_theme == 情绪指数测试")
          getLifeOrEmotionReport(questionnaire, report, scores)
        } else if (questionnaire_theme == themes.POTENTIAL) {
          // console.log("questionnaire_theme == 潜能测试")
          getPotentialReport(questionnaire, report, scores)
        }
        report.questionnaire_info = questionnaire_info

        ReportModel.create(report)
          .then(function (result) {
            report = result.ops[0]
            // console.log('报表添加成功，添加信息如下：')
            // console.log(report)
            res.json({ "success": "true", 'data': report })
          })
      }

    })
    .catch(next)
})

module.exports = router
