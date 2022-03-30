import * as React from 'react'                          
import axios from "axios"
import { Header, Grid, Input, Card, Icon } from 'semantic-ui-react'

class App extends React.Component{
    constructor(props) {
        super(props)
        this.searchInput = React.createRef()
        this.state = {
            fridgeStockIngredients: '',
            gridDisplay: 'none',
            loading:false,
            recipes: [{
                recipy: 1, 
                relevance: '',
                ingredients: []
            }]
        }
    }
    
    handleKeyDown(e){
        this.updateInput(e)
        if (e.key === 'Enter') {
            this.searchRecipes()
        }
    }

    updateInput(e){
        this.setState({fridgeStockIngredients: e.target.value})
    }

    searchRecipes() {
        this.setState({loading: true})

        axios.get("/search?q=" + this.state.fridgeStockIngredients)
            .then((res) => 
                this.setState({
                    recipes: res.data,
                    loading: false, 
                    gridDisplay: 'flex'})
            )

        // this.setState({
        //     recipes: [{"id": 3, "title": 'This is a test recipy'}]
        // })
    }

    showRecipyCompletenessRibbon(complete){
        if (complete == true) {
            return (
                <a className='ui right olive ribbon label' style={{margin: '10px 0'}}>Complete Recipy</a>
            )
        }
    }
    
    componentDidMount(){
        this.searchInput.current.focus();
    }

    render() {
        return (
            <div className='ui container-fluid'> 
                <Grid>
                    <Grid.Column width={8} style={{marginTop: 20}} className='centered'>
                        <Header as='h1'>
                            Welcome to Recipes Finder v0.9
                            <Header.Subheader>
                            Make your search with the ingredients you have.
                            For multiple ingredients, please use comma separated words.
                            </Header.Subheader>
                        </Header>
                        <Input
                            id='search-input'
                            ref={this.searchInput}
                            size='huge'
                            fluid icon='search' 
                            placeholder='Search...'
                            loading={this.state.loading}
                            onKeyDown={e => this.handleKeyDown(e)}
                        />
                    </Grid.Column>
                </Grid>
                <Grid className='container' style={{display: this.state.gridDisplay} }>
                    <Grid.Column width={16}>
                        <Card.Group itemsPerRow={4}>
                        {
                            this.state.recipes.map((recipy, recipyIndex) =>
                                <Card key={recipyIndex} className={recipy.class}>
                                    {/* <div style={{backgroundImage: `url(${recipy.image_url})`,
                                                overflow: 'hidden',
                                                borderRadius: 3,
                                                border: 1,
                                                borderColor: '#ccc',
                                                backgroundSize: 'cover', 
                                                height: 140,
                                                margin: '0'}}>
                                    </div> */}
                                    <Card.Content>
                                    <Card.Header>{recipy.title}</Card.Header>
                                    <Card.Meta>
                                        <span className='date'>{recipy.recipy_category}</span><br />
                                        <span className='date'>Rating {recipy.rating}</span>
                                    </Card.Meta>
                                    {this.showRecipyCompletenessRibbon(recipy.complete)}                 
                                    <Card.Description>
                                        {
                                        recipy.ingredients.map((incredient, incredientIndex) => 
                                            <div className='incredient' key={incredientIndex}>- {incredient.name}</div>
                                            )
                                        }
                                    </Card.Description>
                                    </Card.Content>
                                    <Card.Content extra>
                                        <Grid>
                                            <Grid.Column width={2}>
                                                <Icon name='time' />
                                            </Grid.Column>
                                            <Grid.Column width={13}>
                                                Preperation Time: {recipy.prep_time} <br/>
                                                Cooking Time: {recipy.cook_time} <br/>
                                            </Grid.Column>
                                        </Grid>
                                        <Grid>
                                            <Grid.Column width={2}>
                                                <Icon name='info' />
                                            </Grid.Column>
                                            <Grid.Column width={13}>
                                                Matched Ingredients: {recipy.matched_ingredients_count} <br/>
                                                Non Matched Ingredients: {recipy.non_matched_ingredients_count} <br/>
                                                Completeness: {recipy.completeness} %<br/>
                                            </Grid.Column>
                                        </Grid>
                                    </Card.Content>
                                </Card>                    
                            )
                        }
                        </Card.Group>
                    </Grid.Column>
                </Grid>
            </div>
        )                   
    }
}
                                                        
export default App